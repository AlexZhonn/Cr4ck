import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from '../Header/header';
import { CHALLENGES, TOPICS, Topic } from '../data/challenges';

@Component({
  selector: 'app-problem-set',
  standalone: true,
  imports: [CommonModule, HeaderComponent],
  templateUrl: './problem-set.html',
  styleUrl: './problem-set.css',
})
export class ProblemSetComponent {
  readonly topics = TOPICS;
  readonly totalChallenges = CHALLENGES.length;

  constructor(private router: Router) {}

  countForTopic(topic: Topic): number {
    return CHALLENGES.filter(c => c.topic === topic).length;
  }

  difficultyRange(topic: Topic): string {
    const challenges = CHALLENGES.filter(c => c.topic === topic);
    const has = (d: string) => challenges.some(c => c.difficulty === d);
    const parts: string[] = [];
    if (has('Easy')) parts.push('Easy');
    if (has('Medium')) parts.push('Medium');
    if (has('Hard')) parts.push('Hard');
    return parts.join(' · ');
  }

  goToTopic(topic: Topic) {
    this.router.navigate(['/problems/topic', topic]);
  }
}
