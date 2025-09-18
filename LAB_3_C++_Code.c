
int frame_x;
int fame_y;
int window_x;
int window_y;


int sad_x = frame_x - window_x;
int sad_y = frame_y - window_y;
int sad_Min = 1000000;




// movement 1 (x cord + 1)




//movement 2 (y cord - 1)


//movement 3 (diagonal up-right)

//movement 4 (diagonal left-down)


// sad capture

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



