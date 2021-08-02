import java.util.Random; //<>// //<>//
import java.util.Collections;

Visualizer visualizer;

void setup() {
  size(600, 600, P2D);
  visualizer = new Visualizer(0.75, 0.008);
}

void draw() {
  visualizer.update();
  visualizer.display();
}

class Visualizer {
  float threshold;
  float emptyRatio;
  int[] cells;
  int[] emptyCellIdxs;
  int empty = color(255);

  Visualizer(float t, float e) {
    threshold = t;
    emptyRatio = e;
    cells = new int[width*height];
    emptyCellIdxs = new int[int(cells.length*emptyRatio)];

    for (int i = 0; i < cells.length; ++i) {
      if (i < (cells.length*(1-emptyRatio))/2) {
        cells[i] = color(255, 0, 0);
      } else if (i < cells.length*(1-emptyRatio)) {
        cells[i] = color(0, 0, 255);
      } else {
        cells[i] = empty;
      }
    }
    shuffleArray(cells);

    int idx = 0;
    for (int i = 0; i < cells.length; ++i) {
      if (cells[i] == empty) {
        emptyCellIdxs[idx++] = i;
      }
    }
  }

  void update() {
    ArrayList<Integer> unsatisfiedCellIdxs = new ArrayList<Integer>();
    for (int i = 0; i < cells.length; ++i) {
      if (isCellSatisfied(i) == false) {
        unsatisfiedCellIdxs.add(i);
      }
    }
    Collections.shuffle(unsatisfiedCellIdxs);

    Random rnd = new Random();
    for (int i = 0; i < unsatisfiedCellIdxs.size(); ++i) {
      int unsatisfiedIdx = unsatisfiedCellIdxs.get(i);
      int emptyIdx = rnd.nextInt(emptyCellIdxs.length);

      int tmp = cells[emptyCellIdxs[emptyIdx]];
      cells[emptyCellIdxs[emptyIdx]] = cells[unsatisfiedIdx];
      cells[unsatisfiedIdx] = tmp;

      emptyCellIdxs[emptyIdx] = unsatisfiedIdx;
    }
  }

  void display() {
    loadPixels();
    for (int i = 0; i < cells.length; ++i) {
      pixels[i] = cells[i];
    }
    updatePixels();
  }

  boolean isCellSatisfied(int idx) {
    if (cells[idx] == empty) return true;

    int numOfNeighboursFromTheSameGroup = 0;
    int[] neighbourIdxs = getCellNeighbourIdxs(idx);
    for (int i = 0; i < neighbourIdxs.length; ++i) {
      if (cells[idx] == cells[neighbourIdxs[i]]) {
        ++numOfNeighboursFromTheSameGroup;
      }
    }

    return (float(numOfNeighboursFromTheSameGroup) / float(neighbourIdxs.length)) >= threshold;
  }

  int[] getCellNeighbourIdxs(int idx) {
    int left = getCellLeftNeighbourIdx(idx);
    int top = getCellTopNeighbourIdx(idx);
    int right = getCellRightNeighbourIdx(idx);
    int bottom = getCellBottomNeighbourIdx(idx);

    int topLeft = getCellLeftNeighbourIdx(top);
    int topRight = getCellRightNeighbourIdx(top);
    int bottomLeft = getCellLeftNeighbourIdx(bottom);
    int bottomRight = getCellRightNeighbourIdx(bottom);

    return new int[] { left, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft };
  }

  int getCellLeftNeighbourIdx(int idx) {
    if (idx % width == 0) {
      return idx + width - 1;
    } else {
      return idx - 1;
    }
  }

  int getCellRightNeighbourIdx(int idx) {
    if ((idx+1) % width == 0) {
      return idx - width + 1;
    } else {
      return idx + 1;
    }
  }

  int getCellTopNeighbourIdx(int idx) {
    if (idx < width) {
      return width*height - (width-idx);
    } else {
      return idx - width;
    }
  }

  int getCellBottomNeighbourIdx(int idx) {
    if (idx >= width*(height-1)) {
      return idx - width*(height-1);
    } else {
      return idx + width;
    }
  }
}

void shuffleArray(int[] array) {
  Random rnd = new Random();
  for (int i = array.length-1; i > 0; --i) {
    int idx = rnd.nextInt(i+1);
    int tmp = array[idx];
    array[idx] = array[i];
    array[i] = tmp;
  }
}
