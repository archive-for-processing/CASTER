import java.io.*;
import java.nio.ByteBuffer;
/**
EMImage is a master class to coordinate the actions of EMStack, EMOverlay, and Brush
it is designed to have a single global instance of its self called img //TODO: remove this//, some of the sub classes depend heavily on this master object
EMImage depends on having access to int width, int height, int depth void draw(int layer, float offsetX, float offsetY, float scaleX, float scaleY), and color get(int layer, int x, int y) from EMStack
EMOverlay(int width, int height, int depth), void load(InputStream), and void save(OutputStream) from EMOverlay
Brush(color c), void draw(EMImage this),and ArrayList<Pixel> floodFillBackup from Brush
Pixel(int x, int y, int c) from Pixel
float range(float, float, float) from global
EMOverlay depends on int width, int height, color(int red, int green, int blue, int alpha), and color from processing 
*/
class EMImage {
	public Brush brush;//drawning brush object
	private EMStack img;//EM scan stack
	private float offsetX=00;//screen offset
	private float offsetY=00;
	private float zoom=1;//screen zooom
	public EMOverlay overlay;//overlay images
	public int layer;//layer in overlay and img
  public int prevLayer;
  public ArrayList<EMMeta> meta;//meta data for a given layer
  

	public EMImage(EMStack stack) {//expect the stack to be given to you, theoretically EMImage can deal with making the stack, but currently the loading happens outside for this
		layer=0;
    prevLayer=0;
		img=stack;
		overlay=new EMOverlay(img.width, img.height, img.depth);//create a overlay for the stack
		brush=new Brush(color(255, 0, 0, 50),this,9);//create generic brush
    meta=new ArrayList<EMMeta>();
    for(int i=0;i<img.depth;i++){
      meta.add(new EMMeta()); 
    }
    img.meta=meta;
    overlay.meta=meta;
		this.update();//call update... apparently update does not actually do anything right now..... not sure what it was going to do
	}

	public EMImage draw() {
		img.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the image stack 
		overlay.draw(layer, offsetX+meta.get(layer).offsetX*zoom, offsetY+meta.get(layer).offsetY*zoom, img.width*zoom, img.height*zoom);//draw the over lay OVER that
		brush.draw();//draw the brush on top
		return this.update();//again, why update?
	}
	
	public EMImage move(float x, float y) {
		//calculate the offset allowing for a 1 pixel allowance adjusted by zoom
               offsetX=range(width-zoom, offsetX+x, zoom-img.width*zoom);
              offsetY=range(height-zoom, offsetY+y, zoom-img.height*zoom);
		return this.update();//not sure what I planned for update
	}
	
	public EMImage zoom(float fac) {
		float oldZ=zoom;
		zoom+=(fac)*zoom*.01;
        
		//adjust offset so center pixel does not move
		//to do this find the edge of the image's offset from the center of the screen
		//then divide it by the original zoom and multiply by the new zoom
		//this gives you current offset from center so add it to the center 
		//and you have the offset
		//then apply the range function for safety
		offsetX=width/2+(offsetX-width/2)/oldZ*zoom;
		offsetY=height/2+(offsetY-height/2)/oldZ*zoom;
                move(0,0);//do checking in offset, but dont move this keeps the image from snaping in the next movement
                
		return this.update();//but its here again
	}
	
	public EMImage SetZoom(float zoomTo) {
		return this.zoom(zoomTo-zoom);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public EMImage SetOffset(float x, float y) {
		return this.move(offsetX-x, offsetY-y);//untested, hopefully unused, but you never know, so I am including it
	}
	
	public float getZoom() {
		return zoom;//setting zoom directly would be problematic so it needed to be private, hence a getter
	}
	
	public EMImage update() {
		//... apparently this stub... is just a stub... yah... I don’t know what i was planning to put here so I will probably remove it unless I remember
		return this;
	}
	
	public Pixel getPixel(int screenX, int screenY) {//gets the img pixel at a screen coord
		int x, y;
		color c;
		x=int((screenX-offsetX)/zoom);//+meta.get(layer).offsetX;
		y=int((screenY-offsetY)/zoom);//+meta.get(layer).offsetY;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
	
	public Pixel get(int x, int y) {//just an obfuscation of img.img.get(...) to img.get(...)
		color c;
		c=img.get(layer, x, y);
		return new Pixel(x, y, c);
	}
		
	public EMImage changeLayer(float direction){//changes the current layer, designed for a mouse wheel, expects a signed input so as to decide which direction to go
    
		brush.eStop();
		if (direction>0){//I could probiably optimize this, but with the number of layer changes being so low.... why bother
      prevLayer=layer;//do this inside the if so it does not accidentally trigger
			layer=min(img.depth-1,layer+1);
		}else if (direction<0){
      prevLayer=layer;
			layer=max(0,layer-1);
		}
		return this;
	}

	public boolean save(File fileName){//saves current layout to JEMO format
		try{
			OutputStream file= new BufferedOutputStream(new FileOutputStream(fileName));
			file.write('J'); //setup header
			file.write('E');
			file.write('M');
			file.write('O');
      file.write(0);//NOT A NULL TERMINATOR, write the version number for the file type
			file.write(wrapInt(layer));//write current active layer, I threw this in because I think when I load an overlay I would want to snap to the last position
			overlay.save(file);//turn the saving over to EMOverlay, we expect it to not close the file
			file.flush();
			file.close();
		}catch(IOException ex){
			return false; //very little reason the exception should ever be thrown
		}
		return true;
	}
	
	public byte[] wrapInt(int toWrap){//a method that wraps an int in a byte[] because write(int) ONLY WRITES THE LOW BYTE TO THE FILE!!!!!!!!
		ByteBuffer temp = ByteBuffer.allocate(4);
		temp.putInt(toWrap);//convert int to ByteBuffer
		byte[] conv=new byte[4];//integers are generally 4 bytes, and if that changes for some reason, the file type still thinks ints are 4 bytes so this is constant
		for(int i=0;i<4;i++){//convert ByteBuffer to byte[] (Since for some reason ByteBuffer does not have a .getBytes or similar)
			conv[i]=temp.get(i);
		}
		return conv;
	}

	public boolean load(File fileName){//load JEMO file to overlay, replaces overlay
		try{
			InputStream file = new BufferedInputStream(new FileInputStream(fileName));
			byte[] temp=new byte[4];
			file.read(temp);
			String var=new String(temp);//read and test header
      byte ver;//get version number
      ver=(byte)file.read();
			if(!var.equals("JEMO")){
				println("Invalid file type");
				file.close();
				return false;

			}
      if(ver>0){
        println("file version not suported");
        file.close();
        return false;
      }
			file.read(temp);
			int tLayer=min(ByteBuffer.wrap(temp).getInt(),img.depth-1);//it is very important we don’t change layer yet, processing multithreads
			//file io, so this is running parallel to draw, if we change the layer now there is a very good chance we switch to that layer in the overlay
			//before it exists and we don’t want that
			overlay.load(file);//pass loading EMOverlay
			layer=tLayer;//ok, now that overlay is fully loaded we can safely change layers to the proper layer
			file.close();
			}
		catch(IOException ex){
			println(ex);
			println("exception");
			return false; 
		}
		return true;
	}  

  float greyVal(color c){//this averages the RGB values of a given color to determine its grayscale value
    return ((c >> 16 & 0xFF) + (c >> 8 & 0xF) + (c & 0xFF))/3.0;//extract and average rgb values
  }
  public EMImage alignLandmarks(int size){return alignLandmarks(size,1);}//because FRIKING JAVA DOES NOT ALLOW DEFAULT ARGUMENTS!!!
  
  public EMImage alignLandmarks(int size, int startLayer){//how large of a shift should be considered for a alignment
    for(int l=min(1,startLayer);l<img.depth;l++){
      float bestVal=999999999;//large start
      EMMeta bestPos=new EMMeta();//track the meta of the best spot
      for(int x=-size; x<size;x++){
        for(int y=-size; y<size;y++){
          //println("("+x+","+y+")");//debug line
          float value=0;
          meta.get(l).offsetX=0;
          meta.get(l).offsetY=0;
          for(int i=size;i<img.width-size;i++){
            for (int j=size;j<img.height-size;j++){//5 nested for loops? man I feel bad
              float base =greyVal(img.get(l,x+i,y+j));
              float next=greyVal(img.get(l-1,i,j));//calculate how well the entire image matches to the previous layer
              value+=abs(base-next)/255;
              
            }
          }
          //println(value);
          if(value<bestVal){
            bestVal=value;//check if this shift is better or not
            bestPos.offsetX=-x;
            bestPos.offsetY=-y;
          }
        }
      }
      meta.get(l).offsetX=bestPos.offsetX;
      meta.get(l).offsetY=bestPos.offsetY;
      //println("best ("+bestPos.offsetX+","+bestPos.offsetY+")");
    }
    return this;
  }

}