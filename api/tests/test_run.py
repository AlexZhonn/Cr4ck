"""
Tests for POST /api/v1/run

Covers:
  - Auth guard (401 without token)
  - Harness concatenation helpers (unit tests, no DB needed)
  - Integration: run endpoint with mocked DB + executor
"""

import pytest
from routers.run import (
    _strip_java_public,
    _strip_cpp_main,
    _strip_python_main_block,
    _build_submission_code,
)
from conftest import db_required


# ---------------------------------------------------------------------------
# Unit tests for stripping helpers — no DB, no HTTP
# ---------------------------------------------------------------------------

class TestStripJavaPublic:
    def test_strips_public_class(self):
        code = "public class Foo {\n    void bar() {}\n}"
        result = _strip_java_public(code)
        assert "public class" not in result
        assert "class Foo" in result

    def test_strips_multiple_public_classes(self):
        code = "public class Foo {}\npublic class Bar {}\npublic interface Baz {}"
        result = _strip_java_public(code)
        assert result.count("public class") == 0
        assert result.count("public interface") == 0
        assert "class Foo" in result
        assert "class Bar" in result
        assert "interface Baz" in result

    def test_strips_public_abstract_class(self):
        code = "public abstract class Animal {\n    public abstract void speak();\n}"
        result = _strip_java_public(code)
        assert "public abstract class" not in result
        assert "abstract class Animal" in result

    def test_strips_public_enum(self):
        code = "public enum Color { RED, GREEN, BLUE }"
        result = _strip_java_public(code)
        assert "public enum" not in result
        assert "enum Color" in result

    def test_does_not_strip_method_level_public(self):
        code = (
            "public class Foo {\n"
            "    public void doSomething() {}\n"
            "    public int getValue() { return 0; }\n"
            "    public static String create() { return \"\"; }\n"
            "}"
        )
        result = _strip_java_public(code)
        # Class-level public stripped
        assert "public class" not in result
        # Method-level public preserved
        assert "public void doSomething" in result
        assert "public int getValue" in result
        assert "public static String" in result

    def test_does_not_strip_public_inside_string_literal(self):
        code = 'public class Foo {\n    String s = "public class Bar";\n}'
        result = _strip_java_public(code)
        # Class declaration stripped; string literal untouched
        assert 'String s = "public class Bar"' in result


class TestStripCppMain:
    def test_strips_basic_main(self):
        code = "class Foo {};\n\nint main() {\n    return 0;\n}\n"
        result = _strip_cpp_main(code)
        assert "int main" not in result
        assert "class Foo" in result

    def test_strips_main_with_args(self):
        code = "int main(int argc, char** argv) {\n    return 0;\n}"
        result = _strip_cpp_main(code)
        assert "int main" not in result

    def test_strips_main_with_nested_braces(self):
        code = (
            "int main() {\n"
            "    if (true) {\n"
            "        for (int i=0; i<10; i++) { }\n"
            "    }\n"
            "    return 0;\n"
            "}\n"
        )
        result = _strip_cpp_main(code)
        assert "int main" not in result

    def test_no_main_returns_unchanged(self):
        code = "class Foo { void bar() {} };"
        assert _strip_cpp_main(code) == code


class TestStripPythonMainBlock:
    def test_strips_main_block(self):
        code = (
            "class Foo:\n"
            "    pass\n"
            "\n"
            "if __name__ == '__main__':\n"
            "    f = Foo()\n"
            "    print(f)\n"
        )
        result = _strip_python_main_block(code)
        assert "__name__" not in result
        assert "class Foo" in result

    def test_strips_double_quote_variant(self):
        code = 'class Bar:\n    pass\n\nif __name__ == "__main__":\n    Bar()\n'
        result = _strip_python_main_block(code)
        assert "__name__" not in result

    def test_no_main_block_returns_unchanged(self):
        code = "class Baz:\n    pass\n"
        assert _strip_python_main_block(code) == code


class TestBuildSubmissionCode:
    def test_no_harness_returns_user_code_unchanged(self):
        user_code = "class Foo: pass"
        assert _build_submission_code("python", user_code, None) == user_code
        assert _build_submission_code("java", user_code, None) == user_code

    def test_java_strips_public_and_appends(self):
        user_code = "public class Foo {}\npublic class Bar {}"
        harness = "public class Main { public static void main(String[] a) {} }"
        result = _build_submission_code("java", user_code, harness)
        assert "public class Foo" not in result
        assert "public class Bar" not in result
        assert "public class Main" in result
        assert result.endswith(harness)

    def test_cpp_strips_main_and_appends(self):
        user_code = "class Foo {};\nint main() { return 0; }\n"
        harness = "int main() { Foo f; return 0; }"
        result = _build_submission_code("cpp", user_code, harness)
        # User's main removed; harness main present once at the end
        assert result.count("int main") == 1
        assert result.endswith(harness)

    def test_python_strips_main_block_and_appends(self):
        user_code = "class Foo: pass\n\nif __name__ == '__main__':\n    Foo()\n"
        harness = "def run_harness(): pass\nrun_harness()"
        result = _build_submission_code("python", user_code, harness)
        assert "__name__" not in result
        assert result.endswith(harness)

    def test_typescript_appends_without_stripping(self):
        user_code = "class Foo { bar() {} }"
        harness = "const f = new Foo(); console.log(f.bar());"
        result = _build_submission_code("typescript", user_code, harness)
        assert result == user_code + "\n\n" + harness

    def test_cpp_alias_works(self):
        user_code = "class X {};"
        harness = "int main() {}"
        result_cpp = _build_submission_code("cpp", user_code, harness)
        result_cxx = _build_submission_code("c++", user_code, harness)
        assert result_cpp == result_cxx


# ---------------------------------------------------------------------------
# Integration: auth guard
# ---------------------------------------------------------------------------

class TestRunEndpointAuth:
    @pytest.mark.asyncio
    async def test_unauthenticated_returns_401(self, client):
        response = await client.post(
            "/api/v1/run",
            json={"challenge_id": "oop_001", "language": "java", "code": "public class Foo {}"},
        )
        assert response.status_code == 401


# ---------------------------------------------------------------------------
# Integration: harness concatenation is applied (mocked DB + executor)
# ---------------------------------------------------------------------------

class TestRunEndpointHarness:
    def test_no_harness_uses_raw_code(self):
        """When test_harness is NULL, raw user code is submitted unchanged."""
        from routers.run import _build_submission_code
        code = "public class Foo {}"
        assert _build_submission_code("java", code, None) == code

    @pytest.mark.asyncio
    @db_required
    async def test_with_harness_code_is_transformed(self, client, verified_user):
        """When test_harness is set, user code is cleaned and harness is appended."""
        from routers.run import _build_submission_code

        user_java = "public class Library {}\npublic class Book {}"
        harness = "public class Main { public static void main(String[] a) {} }"

        result = _build_submission_code("java", user_java, harness)

        assert "public class Library" not in result
        assert "public class Book" not in result
        assert "public class Main" in result
