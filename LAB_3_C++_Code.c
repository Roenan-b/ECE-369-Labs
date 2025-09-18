


//FOLLOWING 4 VARIABLES NEED DEDICATED REGISTERS
int frame_x;
int fame_y;
int window_x;
int window_y;


int sadSize_x = frame_x - window_x;
int sadSize_y = frame_y - window_y;
int sad_Min = 1000000;


//NEED DEDICATED REGISTERS
int window_track_x;
int window_track_y;

int sad_window_track_row;   //STORING MINUM SAD ROW
int sad_window_track_column; //STORING MINUM SAD ROW

// movement 1 (x cord + 1)

if ( window_track_y = sadSize_y && (window_track_x < sadSize_x) {
 window_track_x = window_track_x + 1;
}
//RUN FUCNTION sad_capture 
//MOVE TO MOVEMENT 4 AFTER





//movement 2 (y cord - 1)
if ( window_track_x = sadSize_y||window_track_x = 1  && (window_track_y < sadSize_y) {
 window_track_y = window_track_y + 1;
}
//RUN FUCNTION sad_capture
//MOVE TO MOVEMENT 3 AFTER




//movement 3 (diagonal up-right)
while ((window_track_x < sadSize_x) && (window_track_y > 1)) {
  window_track_x++;
  window_track_y++;
  RUN FUNCTION THEN JUMP TO NEXT MOVEMENT
}



//movement 4 (diagonal left-down)
while ((window_track_x > 1) && (window_track_y < sadSize_y)){
  window_track_x--;
  window_track_y--;
   RUN FUNCTION THEN JUMP TO NEXT MOVEMENT
}

// sad capture

//USE TEMP REGISTERS FOR THE COMPARISONS (i and j INSIDE THE FUNCTION)
function sad_capture (int window_x_size, int window_y_size, int frame_i, int frame,j){
  int SAD =0;
  for (int i=1; i < window_x_size; i++){
  for (int j =1; i < window_y_size; j++){
  SAD = SAD + abs(array[i][j] - window[i][j]);  //IN MIPS IT WOULD BE array[i*j] or window[i*j]
  }
  }
  if (SAD < sad_min){
  sad_min = SAD;   //CHECK THIS, either implement the comparison in the function or outside of it.
  }
  return SAD;
}



