# Join an array as a string
local join=${(j/_/)myArray}


# Join only from second element of array
local join=${(j/_/)myArray[2,-1]}


