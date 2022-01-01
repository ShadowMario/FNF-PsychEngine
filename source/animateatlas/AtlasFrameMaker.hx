package animateatlas;
import flixel.util.FlxDestroyUtil;
import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;
import haxe.Json;
import openfl.display.BitmapData;
import animateatlas.JSONData.AtlasData;
import animateatlas.JSONData.AnimationData;
import animateatlas.displayobject.SpriteAnimationLibrary;
import animateatlas.displayobject.SpriteMovieClip;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxFrame;
class AtlasFrameMaker extends FlxFramesCollection{


        //public static var widthoffset:Int = 0;
        //public static var heightoffset:Int = 0;
        //public static var excludeArray:Array<String>;
         /**
	
	 * Creates Frames from TextureAtlas(very early and broken ok) Originally made for FNF HD by Smokey and Rozebud
	 *
	 * @param   key                 The file path.
	 * @param   _excludeArray       Use this to only create selected animations. Keep null to create all of them.
	 *
	 */

        public static function construct(key:String,?_excludeArray:Array<String> = null):FlxFramesCollection{

               // widthoffset = _widthoffset;
               // heightoffset = _heightoffset;
               
               

                var frameCollection:FlxFramesCollection;
                var frameArray:Array<Array<FlxFrame>> = [];
				/*
				
				var modTxtToFind:String = Paths.modsTxt(key);
				var txtToFind:String = Paths.getPath('images/' + key + '/Animation.json', TEXT);
				var dajson = modTxtToFind;
					if (FileSystem.exists(modTxtToFind)){
						dajson = modTxtToFind;
					}
					if (FileSystem.exists(txtToFind)){
						dajson = txtToFind;
					}
					if (Assets.exists(txtToFind)){
						dajson = txtToFind;
					}*/
                var animationData:AnimationData = Json.parse(Paths.getTextFromFile('images/$key/Animation.json'));
                var atlasData:AtlasData = Json.parse(Paths.getTextFromFile('images/$key/spritemap.json'));
                var bitmapData:BitmapData = new BitmapData(0,1);
				
				var pieceOfShit = Paths.image('$key/spritemap');
				if (Std.isOfType(pieceOfShit,FlxGraphic)){
					bitmapData = pieceOfShit.bitmap;
				}else if (Std.isOfType(pieceOfShit,String)){
					bitmapData = Assets.getBitmapData(Paths.image('$key/spritemap'));
				}
                var ss = new SpriteAnimationLibrary(animationData, atlasData, bitmapData);
                var t = ss.createAnimation();
                if(_excludeArray == null){
                _excludeArray = t.getFrameLabels();
                //trace('creating all anims');
                }
                else
                trace('Creating :' + _excludeArray);
                frameCollection = new FlxFramesCollection(FlxGraphic.fromBitmapData(bitmapData),FlxFrameCollectionType.IMAGE);

                
                for(x in _excludeArray){

                        frameArray.push(getFramesArray(t, x));


                }

                for(x in frameArray){
                        for(y in x){
                                frameCollection.pushFrame(y);
                        }
                }
                bitmapData.dispose();
                return frameCollection;

        }

        @:noCompletion static function getFramesArray(t:SpriteMovieClip,animation:String):Array<FlxFrame>
        {
                var sizeInfo:Rectangle = new Rectangle(0,0);
                t.currentLabel = animation;
                var bitMapArray:Array<BitmapData> = [];
                var daFramez:Array<FlxFrame> = [];
                var firstPass = true;
                var frameSize:FlxPoint = new FlxPoint(0,0);

                for (i in t.getFrame(animation)...t.numFrames){
                        t.currentFrame = i;
                        if (t.currentLabel == animation){
                                sizeInfo = t.getBounds(t);
                                var bitmapShit:BitmapData = new BitmapData(
                                Std.int(sizeInfo.width + sizeInfo.x),Std.int(sizeInfo.height + sizeInfo.y),true,0);
                                bitmapShit.draw(t,null,null,null,null,true);
                                bitMapArray.push(bitmapShit);
                                if (firstPass){
                                frameSize.set(bitmapShit.width,bitmapShit.height);
                                firstPass = false;       
                                }
                        }
                        else break;
                }
                
                for (i in 0...bitMapArray.length){
                        var b = FlxGraphic.fromBitmapData(bitMapArray[i]);
                        var theFrame = new FlxFrame(b);
                        theFrame.parent = b;
                        theFrame.name = animation + i;
                        theFrame.sourceSize.set(frameSize.x,frameSize.y);
                        theFrame.frame = new FlxRect(0, 0, bitMapArray[i].width, bitMapArray[i].height);
                        daFramez.push(theFrame);
                     

                        
                        //trace(daFramez);
                }
                return daFramez;
        }

      
        
        

}