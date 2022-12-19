package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ErrorDisplay
{
    public var text(default, set):String = 'Error!';

    public var errorBG:FlxSprite;
    public var errorText:FlxText;

    // Tween stuff
    public var bgAlpha:Float = 0.6; // the BG's alpha when it becomes visible
    public var bgPersistence:Float = 3; // how long the BG stays

    public var textAlpha:Float = 1; // the text's alpha when it becomes visible
    public var textPersistence:Float = 3; // how long the text stays

    public var errorBGTween:FlxTween;
    public var errorTextTween:FlxTween;

    private function set_text(val:String):String
    {
        text = val;
        this.errorText.text = text;
		this.errorText.screenCenter(); // just to be sure
        return val;
    }

    /**
     * Creates a new ErrorDisplay instance.
     */
    public function new(?errorMessage:String = 'Error!')
    {
        this.errorBG = new FlxSprite().makeGraphic(FlxG.width, 160, 0xFF000000);
		this.errorBG.scrollFactor.set();
		this.errorBG.alpha = 0;
		this.errorBG.screenCenter();

        this.errorText = new FlxText(0, 0, FlxG.width, '', 32);
		this.errorText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		this.errorText.scrollFactor.set();
		this.errorText.alpha = 0;
		this.text = errorMessage;
    }

    /**
     * Displays the error you set.
	 * Example:
	 ** `myDisplay.text = errorString;`
	 ** `myDisplay.displayError();`
     */
    public function displayError()
    {
        if(this.errorBGTween != null) {
			this.errorBGTween.cancel();
			this.errorBGTween.destroy();
			errorBG.alpha = 0;
		}
		if(this.errorTextTween != null) {
			this.errorTextTween.cancel();
			this.errorTextTween.destroy();
			errorText.alpha = 0;
		}

		this.errorBGTween = FlxTween.tween(errorBG, {alpha: bgAlpha}, 0.5, {
			ease: FlxEase.sineOut,
			onComplete: function(twn:FlxTween) {
				this.errorBGTween = FlxTween.tween(errorBG, {alpha: 0}, 0.5, {
					startDelay: bgPersistence,
					ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						this.errorBGTween.destroy();
					}
				});
			}
		});
		
		this.errorTextTween = FlxTween.tween(errorText, {alpha: textAlpha}, 0.5, {
			ease: FlxEase.sineOut,
			onComplete: function(twn:FlxTween) {
				this.errorTextTween = FlxTween.tween(errorText, {alpha: 0}, 0.5, {
					startDelay: textPersistence,
					ease: FlxEase.sineOut,
					onComplete: function(twn:FlxTween) {
						this.errorTextTween.destroy();
					}
				});
			}
		});
    }

    /**
     * Add the display to the state (make it visible)
     * Example: `myDisplay.addDisplay(this);`
     * @param state Which state to add it to
     */
    public function addDisplay(state:FlxState)
    {
        state.add(this.errorBG);
        state.add(this.errorText);
    }

	/**
	 * Destroys the instance.
	 * Do `myDisplay = null;` afterwards to get rid of it completely.
	 */
	public function destroy()
	{
		this.errorBG.destroy();
		this.errorText.destroy();

		this.errorBGTween.destroy();
		this.errorTextTween.destroy();
	}

    /**
     * Removes the display by `.kill()`ing the text and BG
     * @param destroy [Optional] destroy the sprites (just do `myDisplay.destroy();` instead)
     */
    public function remove(?destroy:Bool = false)
    {
        if (destroy)
        {
            this.errorBG.kill();
            this.errorText.kill();
        } else {
            this.destroy();
        }
    }
}