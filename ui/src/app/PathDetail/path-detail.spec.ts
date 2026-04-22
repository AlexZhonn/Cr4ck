import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PathDetailComponent } from './path-detail';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { ActivatedRoute } from '@angular/router';

describe('PathDetailComponent', () => {
  let component: PathDetailComponent;
  let fixture: ComponentFixture<PathDetailComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PathDetailComponent],
      providers: [
        provideRouter([]),
        provideHttpClient(),
        {
          provide: ActivatedRoute,
          useValue: { snapshot: { paramMap: { get: () => 'oop-foundations' } } },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(PathDetailComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should start in loading state', () => {
    expect(component.isLoading()).toBeTrue();
    expect(component.error()).toBeNull();
    expect(component.path()).toBeNull();
  });

  it('progressPercent returns 0 when no progress loaded', () => {
    expect(component.progressPercent()).toBe(0);
  });

  it('difficultyClass returns correct css class', () => {
    expect(component.difficultyClass('Easy')).toBe('badge-easy');
    expect(component.difficultyClass('Medium')).toBe('badge-medium');
    expect(component.difficultyClass('Hard')).toBe('badge-hard');
  });

  it('topicLabel returns correct label', () => {
    expect(component.topicLabel('OOP')).toBe('OOP');
    expect(component.topicLabel('Design Patterns')).toBe('Design Patterns');
    expect(component.topicLabel('System Design')).toBe('System Design');
    expect(component.topicLabel(null)).toBe('Multi-topic');
  });

  it('scoreClass reflects score ranges', () => {
    expect(component.scoreClass(95)).toBe('score-excellent');
    expect(component.scoreClass(75)).toBe('score-good');
    expect(component.scoreClass(55)).toBe('score-fair');
    expect(component.scoreClass(30)).toBe('score-low');
  });

  it('getStepProgress returns null when no progress loaded', () => {
    expect(component.getStepProgress('oop_001')).toBeNull();
  });

  it('descriptionPreview returns first non-markdown line', () => {
    const description =
      '**Requirements:**\n- item one\nDesign a simple library system.\n\nMore details.';
    expect(component.descriptionPreview(description)).toBe('Design a simple library system.');
  });
});
