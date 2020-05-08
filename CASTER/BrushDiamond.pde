class BrushDiamond extends Brush{
      public BrushDiamond(color col,EMImage image,int s){
      super(col,image,s);
    }
    public BrushDiamond draw(){//this draws the shape of the brush to the screen, generally should not update overlay unless there is a multi-frame process
    //this should be called every frame
    log.start("BrushDiamond.draw");
    float zoom=this.img.getZoom();
    Pixel pixel = brushPosition();
    //draw shape centered on mouse
    image(shape,(pixel.x*zoom+this.img.offsetX),(pixel.y*zoom+this.img.offsetY),shape.width*zoom,shape.height*zoom); 
      log.stop();
    return this; 
  }
    public BrushDiamond paint(EMImage img){//this causes the brush to lay down "ink" on the overlay and generally should only be called on mouse press or mouse drag
    log.start("BrushDiamond.paint()");
    Pixel pixel= brushPosition();
    this.img=img;
    for (int x=0;x<this.img.overlay.width&&x<shape.width;x++){
        for (int y=0;y<this.img.overlay.width&&y<shape.width;y++){
          if(erase){//determine if ink is to be removed or layed down
            if(shape.get(x,y)!=color(0,0,0,0)){
              if(this.img.overlay.get(this.img.layer,pixel.x+x,pixel.y+y)==c){//only errase the color that the brush is
                this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,color(0,0,0,0));//note iff a pixel is non transparent it will remove set the overlay transparent
              }
            }
          }else{
            if(shape.get(x,y)!=color(0,0,0,0)){//this prevents brushes from having visible edges
              this.img.overlay.set(this.img.layer,pixel.x+x,pixel.y+y,shape.get(x,y));
            }
          }
        }  
      }
      log.stop();
    return this;
  }
  
  public BrushDiamond update(){//updates the shape of the brush, this should only be called when there is a reasonable certainty that the brush has changed in some way
    //as it can be a computationally complex operation
    log.start("BrushDiamond.update()");
      shape=createImage((int)size,(int)size,ARGB);
      for(int x=0;x<shape.width;x++){
        for(int y=0;y<shape.height;y++){
          float posX=x-shape.width/2;
          float posY=y-shape.height/2;
          if (abs(posX)+abs(posY)<size/2){//this took some head scratching, essentially this is the exact same as a circle... just don’t square every term
            shape.set(x,y,c);
          }
        }
      }
      log.stop();
    return this;
  }
  
}
