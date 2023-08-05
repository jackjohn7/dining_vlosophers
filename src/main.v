module main

import sync { new_mutex, Mutex }
import time
import rand { i64_in_range }

type Fork = Mutex

struct Philosopher {
  id int [required]
  mut:
    left_fork &Fork [required]
    right_fork &Fork [required]
    apetite int [required]
}

fn (self &Philosopher) think() {
  println("Philosopher ${self.id + 1} is thinking")
  rnd_sleep := i64_in_range(0, 200) or {80}
  time.sleep(rnd_sleep * time.millisecond)
}

fn (self &Philosopher) eat() {
  println("Philosopher ${self.id + 1} is eating")
  rnd_sleep := i64_in_range(0, 200) or {80}
  time.sleep(rnd_sleep * time.millisecond)
}

fn (mut self Philosopher) dine() {
  for self.apetite != 0 {
    self.think()
    // even philosophers grab left fork first
    if self.id % 2 == 0 {
      self.left_fork.@lock()
      self.right_fork.@lock()
    } else {
      self.right_fork.@lock()
      self.left_fork.@lock()
    }
    self.eat()

    self.apetite -= 1
    // release the forks
    self.left_fork.unlock()
    self.right_fork.unlock()
  }
}

fn main() {
  num_phils := 10
  apetite := 10
	println('Hello World!')

  // Create forks
  mut forks := []&Fork{}

  for _ in 0 .. num_phils {
    forks << new_mutex()
  }

  // Create philosophers and threads
  mut phils := []&Philosopher{}
  mut threads := []thread{}

  for i in 0 .. num_phils {
    phils << &Philosopher{id: i,
      left_fork: forks[i],
      right_fork: fn [i, forks, num_phils] () &Fork {
        if i + 1 == num_phils {
          return forks[0]
        }
        return forks[i + 1]
      }(),
      apetite: apetite}
    threads << spawn phils[i].dine()
  }
  // forks[0].@lock()
  // forks[0].unlock()

  threads.wait()
  println("Done")
}
