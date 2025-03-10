import de.bezier.guido.*;

private static final int NUM_ROWS = 20; 
private static final int NUM_COLS = 20; 
private static final int NUM_MINES = 50; 
private MSButton[][] buttons; 
private ArrayList<MSButton> mines; 

void setup() {
  size(600, 600); 
  textAlign(CENTER, CENTER);
  
  Interactive.make(this);
  
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      buttons[row][col] = new MSButton(row, col);
    }
  }
  
  mines = new ArrayList<MSButton>();
  setMines();
}

public void setMines() {
  while (mines.size() < NUM_MINES) {
    int row = (int) random(NUM_ROWS);
    int col = (int) random(NUM_COLS);
    MSButton button = buttons[row][col];
    if (!mines.contains(button)) {
      mines.add(button);
      button.setMine(true); 
    }
  }
}

public void draw() {
  background(0);
  
  if (isWon()) {
    displayWinningMessage();
  }
  
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      buttons[row][col].draw();
    }
  }
}

public boolean isWon() {
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      MSButton button = buttons[row][col];
      if (!button.isClicked() && !mines.contains(button)) {
        return false; 
      }
    }
  }
  return true; 
}

public void displayWinningMessage() {
  String message = "You Win! :D";
  for (int row = NUM_ROWS / 2 - 1; row < NUM_ROWS / 2 + 2; row++) {
    for (int col = NUM_COLS / 2 - 6; col < NUM_COLS / 2 + 6; col++) {
      MSButton button = buttons[row][col];
      button.setLabel(message.charAt((row - NUM_ROWS / 2 + 1) * 12 + (col - NUM_COLS / 2 + 6)) + "");
    }
  }
}

public void displayLosingMessage() {
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      MSButton button = buttons[row][col];
      if (mines.contains(button)) {
      }
    }
  }
  String message = "You Lose! :(";
  for (int row = NUM_ROWS / 2 - 1; row < NUM_ROWS / 2 + 2; row++) {
    for (int col = NUM_COLS / 2 - 6; col < NUM_COLS / 2 + 6; col++) {
      MSButton button = buttons[row][col];
      button.setLabel(message.charAt((row - NUM_ROWS / 2 + 1) * 12 + (col - NUM_COLS / 2 + 6)) + "");
    }
  }
}

public boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  
  for (int r = -1; r <= 1; r++) {
    for (int c = -1; c <= 1; c++) {
      if (r == 0 && c == 0) continue; // Skip the current cell
      if (isValid(row + r, col + c) && mines.contains(buttons[row + r][col + c])) {
        numMines++;
      }
    }
  }
  
  return numMines;
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged, isMine;
  private String myLabel;

  public MSButton(int row, int col) {
    width = 600 / NUM_COLS;
    height = 600 / NUM_ROWS;
    myRow = row;
    myCol = col;
    x = myCol * width;
    y = myRow * height;
    myLabel = "";
    flagged = clicked = false;
    isMine = false;
    Interactive.add(this); 
  }

  public void mousePressed() {
    clicked = true;
    if (isMine) {
      displayLosingMessage(); 
    } else {
      int numMines = countMines(myRow, myCol);
      if (numMines > 0) {
        setLabel(numMines);
      } else {
        revealNeighbors(myRow, myCol);
      }
    }
  }

  public void revealNeighbors(int row, int col) {
    for (int r = -1; r <= 1; r++) {
      for (int c = -1; c <= 1; c++) {
        if (r == 0 && c == 0) continue; 
        int newRow = row + r;
        int newCol = col + c;
        if (isValid(newRow, newCol) && !buttons[newRow][newCol].isClicked() && !buttons[newRow][newCol].isMine) {
          buttons[newRow][newCol].setLabel(countMines(newRow, newCol));
          buttons[newRow][newCol].clicked = true;
          if (countMines(newRow, newCol) == 0) {
            revealNeighbors(newRow, newCol); 
          }
        }
      }
    }
  }

  public void draw() {
    if (flagged) {
      fill(0);
    } else if (clicked && isMine) {
      fill(250, 52, 121); 
    } else if (clicked) {
      fill(255, 189, 212); 
    } else {
      fill(255, 122, 169); 
    }
    
    rect(x, y, width, height);
    fill(0);
    text(myLabel, x + width / 2, y + height / 2); // Display label (mine count or "You Suck, Loser!")
  }

  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }

  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }

  public boolean isClicked() {
    return clicked;
  }

  public boolean isMine() {
    return isMine;
  }

  public void setMine(boolean mineStatus) {
    isMine = mineStatus;
  }
}
