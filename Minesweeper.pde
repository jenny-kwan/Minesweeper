import de.bezier.guido.*;

private static final int NUM_ROWS = 20; // Increased to 20 for a larger grid
private static final int NUM_COLS = 20; // Increased to 20 for a larger grid
private static final int NUM_MINES = 50; // Adjusted to a reasonable number of mines for a larger grid
private MSButton[][] buttons; // 2d array of minesweeper buttons
private ArrayList<MSButton> mines; // ArrayList of just the minesweeper buttons that are mined

void setup() {
  size(600, 600); // Adjusted size to fit a larger grid
  textAlign(CENTER, CENTER);
  
  // make the manager
  Interactive.make(this);
  
  // Initialize the 2D array of MSButton objects
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
  // Generate random positions for mines
  while (mines.size() < NUM_MINES) {
    int row = (int) random(NUM_ROWS);
    int col = (int) random(NUM_COLS);
    MSButton button = buttons[row][col];
    if (!mines.contains(button)) {
      mines.add(button);
      button.setMine(true); // Set the button to be a mine
    }
  }
}

public void draw() {
  background(0);
  
  // Check if the player has won and display a winning message if true
  if (isWon()) {
    displayWinningMessage();
  }
  
  // Draw the grid of buttons
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      buttons[row][col].draw();
    }
  }
}

// Check if the player has won
public boolean isWon() {
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      MSButton button = buttons[row][col];
      if (!button.isClicked() && !mines.contains(button)) {
        return false; // If there's an unclicked non-mine button, the game is not won yet
      }
    }
  }
  return true; // All non-mine buttons are clicked
}

// Display the winning message
public void displayWinningMessage() {
  String message = "You Win! :D";
  for (int row = NUM_ROWS / 2 - 1; row < NUM_ROWS / 2 + 2; row++) {
    for (int col = NUM_COLS / 2 - 6; col < NUM_COLS / 2 + 6; col++) {
      MSButton button = buttons[row][col];
      button.setLabel(message.charAt((row - NUM_ROWS / 2 + 1) * 12 + (col - NUM_COLS / 2 + 6)) + "");
    }
  }
}

// Display the losing message
public void displayLosingMessage() {
  for (int row = 0; row < NUM_ROWS; row++) {
    for (int col = 0; col < NUM_COLS; col++) {
      MSButton button = buttons[row][col];
      if (mines.contains(button)) {
        // You can choose to display something when a mine is revealed here if needed
      }
    }
  }
  // After all mines are revealed, display the losing message
  String message = "You Lose! :(";
  for (int row = NUM_ROWS / 2 - 1; row < NUM_ROWS / 2 + 2; row++) {
    for (int col = NUM_COLS / 2 - 6; col < NUM_COLS / 2 + 6; col++) {
      MSButton button = buttons[row][col];
      button.setLabel(message.charAt((row - NUM_ROWS / 2 + 1) * 12 + (col - NUM_COLS / 2 + 6)) + "");
    }
  }
}

// Check if a position is valid on the grid
public boolean isValid(int r, int c) {
  return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

// Count the number of neighboring mines for a button
public int countMines(int row, int col) {
  int numMines = 0;
  
  // Check all 8 neighboring cells
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

// MSButton class definition
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
    Interactive.add(this); // Register it with the manager
  }

  // Called by the manager when a mouse is pressed
  public void mousePressed() {
    clicked = true;
    if (isMine) {
      displayLosingMessage(); // Reveal mines and show the losing message
    } else {
      int numMines = countMines(myRow, myCol);
      if (numMines > 0) {
        setLabel(numMines);
      } else {
        // Recursively reveal neighboring cells if no mines are around
        revealNeighbors(myRow, myCol);
      }
    }
  }

  // Recursively reveal neighbors if no mines are present around this button
  public void revealNeighbors(int row, int col) {
    for (int r = -1; r <= 1; r++) {
      for (int c = -1; c <= 1; c++) {
        if (r == 0 && c == 0) continue; // Skip the current cell
        int newRow = row + r;
        int newCol = col + c;
        if (isValid(newRow, newCol) && !buttons[newRow][newCol].isClicked() && !buttons[newRow][newCol].isMine) {
          buttons[newRow][newCol].setLabel(countMines(newRow, newCol));
          buttons[newRow][newCol].clicked = true;
          if (countMines(newRow, newCol) == 0) {
            revealNeighbors(newRow, newCol); // Recursively reveal more if no mines are around
          }
        }
      }
    }
  }

  // Draw the button
  public void draw() {
    if (flagged) {
      fill(0);
    } else if (clicked && isMine) {
      fill(250, 52, 121); // Red color for mines
    } else if (clicked) {
      fill(255, 189, 212); // Light gray for clicked buttons
    } else {
      fill(255, 122, 169); // Dark gray for unclicked buttons
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
