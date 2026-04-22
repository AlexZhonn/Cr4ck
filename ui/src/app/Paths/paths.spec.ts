import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PathsComponent } from './paths';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

describe('PathsComponent', () => {
  let component: PathsComponent;
  let fixture: ComponentFixture<PathsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PathsComponent],
      providers: [provideRouter([]), provideHttpClient()],
    }).compileComponents();

    fixture = TestBed.createComponent(PathsComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should start in loading state', () => {
    expect(component.isLoading()).toBeTrue();
    expect(component.error()).toBeNull();
    expect(component.paths().length).toBe(0);
  });

  it('topicLabel returns correct label for known topics', () => {
    expect(component.topicLabel('OOP')).toBe('OOP');
    expect(component.topicLabel('Design Patterns')).toBe('Patterns');
    expect(component.topicLabel('System Design')).toBe('System Design');
    expect(component.topicLabel(null)).toBe('Multi-topic');
  });

  it('topicClass returns correct css class', () => {
    expect(component.topicClass('OOP')).toBe('topic-oop');
    expect(component.topicClass('Design Patterns')).toBe('topic-patterns');
    expect(component.topicClass('System Design')).toBe('topic-system');
    expect(component.topicClass(null)).toBe('topic-other');
  });

  it('difficultyClass returns correct css class', () => {
    expect(component.difficultyClass('Easy')).toBe('diff-easy');
    expect(component.difficultyClass('Medium')).toBe('diff-medium');
    expect(component.difficultyClass('Hard')).toBe('diff-hard');
    expect(component.difficultyClass('Unknown')).toBe('');
  });
});
