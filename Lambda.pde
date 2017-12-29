/**
implements a rough lambda concept since processing does not have it by default
the Lambda class is technically abstract, but has been declared otherwise so as a empty Lambda can be created by default
this has been implemented to allow clickable buttons
collectively all implemented lambda functions depend on access to global EMImage img, Brush img.brush, int img.brush, void img.brush.update(), void img.brush.clearBrush(), void img.save(), void img.load()
these also depend on void selectInput(String path, String function, Object this) and void selectOutput(String path, String function,Object this) from processing
*/
class Lambda{
	Lambda(){}//all lambda objects will have a default constructor and run()
	public void run(){}
}

class CircleBrush extends Lambda{//allows for circle brush button
	void run(){
   
		img.brush= new BrushCircle(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
	}
}

class SquareBrush extends Lambda{//allows for square brush button
	void run(){
  
            
		img.brush= new BrushSquare(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
     
	}
}
class RayCastBrush extends Lambda{//allows for raycast brush button
  void run(){
 
       img.brush= new RayCast(img.brush.c,img.brush.img,img.brush.size);
      img.brush.erase=((Ui_Button)ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button

  }
}
class DiamondBrush extends Lambda{//allows for diamond brush button
	void run(){
    
		img.brush= new BrushDiamond(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
      
	}
}

class FloodBrush extends Lambda{//allows for flood fill button
	void run(){
         
		img.brush= new BrushFill(img.brush.c,img.brush.img,img.brush.size);
                img.brush.erase=((Ui_Button)ui.getId("eraser")).state.get(0);//change eraser state to the right one based on the button
    
	}
}
/* posibly out dated with new polymorphic Brushes
class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
	int n;
	ClearBrush(){//just to be safe
		n=0; 
	}
	
	ClearBrush(int in){//allow specification of brush to clear, helps prevent radio button errors
		n=in;
	}
	
	void run(){
		img.brush.clearBrush(n);
	}
}*/
class ClearBrush extends Lambda{//allows for clear brush button that is tuned to specific brush via constructor
  ClearBrush(){}
  ClearBrush(int in){}
  void run(){img.brush= new Brush(img.brush.c,img.brush.img,img.brush.size);}
}//large chunks of code depend on this existing, but they dont care if it actually does anything
class EraserBrush extends Lambda{//allows for erase mode button
	boolean state;
	EraserBrush(boolean b){
		state=b;
	}
	
	void run(){
		img.brush.erase=state;

	}
}

public class Save extends Lambda{//allows for overlay save button
        public void run(){
        	selectOutput("Select file to save overlay","handler",new File(""),this);
        
        }
	
	public void handler(File f){//this gets called by selectOutput when the output is selected
		if(f!=null){
		img.save(f); 
		} 
	}
}

public class Load extends Lambda{//allow for overlay load button 
	public void run(){
		selectInput("Select file to load","handler",new File(""),this);
	}

	public void handler(File f){//this gets called by selectInput when the input is selected
		img.load(f);
	}
}
public class BlankButton extends Lambda{//blank button for testing, hyjack all you want
  public void run(){
    //img.alignLandmarks(5);//hyjacked for stack alignment
    LayerSeeded.seedFromPrev(img);//hyjack for seeding
  }

}