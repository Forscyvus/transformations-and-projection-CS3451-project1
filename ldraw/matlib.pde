// CS 3451 Spring 2013 Homework 1 Stub
// Dummy routines for matrix transformations.
// These are for you to write!

void testytime() {
  gtMatrix m = new gtMatrix();
  gtMatrix n = new gtMatrix();
  for(int c = 0; c < 4; c++){
    for(int r = 0; r < 4; r++){
      m.data[c][r] = (c-r)+1;
      n.data[c][r] = (c+r)-1;
    }
  }
  
  gtVector v = new gtVector(3,4,5);
  println("vcrossie");
  println(v.crossie(new gtVector(1,2,3)).data);
  
//  println("m");
//  for(int c = 0; c < 4; c++){
//    println(m.data[c]);
//  }
//  println("n");
//  for(int c = 0; c < 4; c++){
//    println(n.data[c]);
//  }
//  
//  m.matMult(n);
//  println("mn");
//  for(int c = 0; c < 4; c++){
//    println(m.data[c]);
//  }
  
  
}

gtMatrix ctm;
float near;
float far;
float left;
float right;
float top;
float bottom;
float fov;
gtVector draw;
boolean drawing;
boolean halfdone;
int proj;

static final int GT_ORTHO = 0;
static final int GT_PERSPEC = 1;

void gtInitialize() {
  ctm = new gtMatrix();
  proj = GT_ORTHO;
}

void gtPushMatrix() {
  gtMatrix newctm = new gtMatrix();
  newctm.data = ctm.data;
  newctm.next = ctm;
  ctm = newctm;
}

void gtPopMatrix() {
  if (ctm.next == null){
    println("Can't pop, only one matrix on stack.");
    return;
  }
  ctm = ctm.next;
}

void gtTranslate(float tx, float ty, float tz) {
  gtMatrix newmat = new gtMatrix();
  newmat.data[3][0] = tx;
  newmat.data[3][1] = ty;
  newmat.data[3][2] = tz;
  
  ctm.matMult(newmat);
}

void gtScale(float sx, float sy, float sz) {
  gtMatrix newmat = new gtMatrix();
  newmat.data[0][0] = sx;
  newmat.data[1][1] = sy;
  newmat.data[2][2] = sz;
  
  ctm.matMult(newmat);
}

void gtRotate(float angle, float ax, float ay, float az) {
  gtVector Xaxis = new gtVector(ax,ay,az);
  Xaxis.normie();
  
  gtVector N = new gtVector(0,1,0);
  if (ax == 0) {
    N = new gtVector(1,0,0);
  }
  
  gtVector Yaxis = Xaxis.crossie(N);
  Yaxis.normie();
  
  gtVector Zaxis = Xaxis.crossie(Yaxis);
  Zaxis.normie();
  
  gtMatrix R = new gtMatrix();
  for(int r = 0; r < 3; r++){
    R.data[r][0] = Xaxis.data[r];
    R.data[r][1] = Yaxis.data[r];
    R.data[r][2] = Zaxis.data[r];
  }
  
  gtMatrix rot = new gtMatrix();
  rot.data[1][1] = cos(radians(angle));
  rot.data[2][1] = -sin(radians(angle));
  rot.data[1][2] = sin(radians(angle));
  rot.data[2][2] = cos(radians(angle));
  
  ctm.matMult(R.trans());
  ctm.matMult(rot);
  ctm.matMult(R);
 
}

void gtPerspective(float fovy, float nnear, float ffar) {
//  println("perspec params: " + fovy + " " + nnear + " " + ffar);
  fov = fovy;
  near = -nnear;
  far = -ffar;
  
  proj = GT_PERSPEC;
  println("proj: " + proj);
}

void gtOrtho(float left, float right, float bottom, float top, float nnear, float ffar) {
//  println("ortho params: " + left + " " + right + " " + bottom + " " + top + " " + nnear + " " + ffar);
  near = -nnear;
  far = -ffar;
  this.right = right;
  this.left = left;
  this.bottom = bottom;
  this.top = top;
  
  proj = GT_ORTHO;
  
}

void gtBeginShape(int type) {
  if (type != GT_LINES){
   return;
  }
  if (!drawing){
   drawing = true;
   halfdone = false;
  } 
}

void gtEndShape() {
  if (drawing) {
    drawing = false;
  }
  halfdone = false;
}



void gtVertex(float x, float y, float z) {
  if (halfdone) {
    gtVector end = new gtVector(x,y,z);
    end = ctm.transformVector(end);
    
    xyz xyzDraw = new xyz(draw.data[0], draw.data[1], draw.data[2]);
    xyz xyzEnd = new xyz(end.data[0], end.data[1], end.data[2]);
    
    
    if (near_far_clip(near, far, xyzDraw, xyzEnd) == 1) {
      if (proj == GT_ORTHO){
        
        xyzDraw.x = ( (xyzDraw.x - left) * (360.0 / (right - left)) );
        xyzDraw.y = ( (xyzDraw.y - bottom) * (360.0 / (top - bottom)) );
        
        xyzEnd.x = ( (xyzEnd.x - left) * (360.0 / (right - left)) );
        xyzEnd.y = ( (xyzEnd.y - bottom) * (360.0 / (top - bottom)) );
        
        draw_line(xyzDraw.x, xyzDraw.y, xyzEnd.x, xyzEnd.y);
//        println("line drawn: (" + xyzDraw.x + "," + xyzDraw.y  + ") (" + xyzEnd.x + "," + xyzEnd.y + ")");
      } 
      if (proj == GT_PERSPEC){
        println("what");
        float drawxp = xyzDraw.x / abs(xyzDraw.z);
        float drawyp = xyzDraw.y / abs(xyzDraw.z);
        float endxp = xyzEnd.x / abs(xyzEnd.z);
        float endyp = xyzEnd.y / abs(xyzEnd.z);
        float k = tan(radians(fov/2));
        
        float drawxpp = (drawxp + k) * (360 / (2 * k));
        float drawypp = (drawyp + k) * (360 / (2 * k));
        float endxpp = (endxp + k) * (360 / (2 * k));
        float endypp = (endyp + k) * (360 / (2 * k));
        
        
        
        draw_line(drawxpp,drawypp,endxpp,endypp);
//        println("line drawn: (" + drawxpp + "," + drawypp + ") (" + endxpp + "," + endypp + ")");

        
      }
    }
    halfdone = false;
  }
  else {
    draw = new gtVector(x,y,z);
    draw = ctm.transformVector(draw);
    halfdone = true;
  }
  
}

class gtMatrix {
  
  float[][] data;
  
  gtMatrix next;
  
  public gtMatrix(){
    data = new float[4][4];
    for(int i = 0; i < 4; i++){
      data[i][i] = 1.0;
    }
  }
  
  void matMult(gtMatrix m){
    gtMatrix temp = new gtMatrix();
    for(int r = 0; r < 4; r++){
      for(int c = 0; c < 4; c++){
        float entry = 0;
        for(int run = 0; run < 4; run++){
          entry += data[run][r] * m.data[c][run];
        }
        temp.data[c][r] = entry;
      }
    }
    data = temp.data;
  }
  
  gtVector transformVector(gtVector v){
    gtVector result = new gtVector(0,0,0);
    result.data[3] = 0;
    for(int entry = 0; entry < 4; entry++){
      for(int c = 0; c < 4; c++){
        result.data[entry] += v.data[c] * data[c][entry];
      }
    }
    return result;
  }
  
  gtMatrix trans(){
    gtMatrix result = new gtMatrix();
    for(int r = 0; r < 4; r++){
      for(int c = 0; c < 4; c++){
        result.data[r][c] = data[c][r];
      }
    }
    return result;
  }
    
}

class gtVector {
  
  float[] data;
  
  public gtVector(float x, float y, float z){
    data = new float[4];
    data[0] = x;
    data[1] = y;
    data[2] = z;
    data[3] = 1;
  }
  
  float magnitude(){
    return sqrt((data[0]*data[0])+(data[1]*data[1])+(data[2]*data[2]));
  }
  
  void normie(){
    float mag = magnitude();
    for (int i = 0; i < 3; i++){
      data[i] = data[i]/mag;
    }
  }
  
  gtVector crossie(gtVector v){
    gtVector result = new gtVector(0,0,0);
    result.data[0] = (data[1]*v.data[2]) - (data[2]*v.data[1]);
    result.data[1] = (data[2]*v.data[0]) - (data[0]*v.data[2]);
    result.data[2] = (data[0]*v.data[1]) - (data[1]*v.data[0]);
    return result;
  }
  
}
