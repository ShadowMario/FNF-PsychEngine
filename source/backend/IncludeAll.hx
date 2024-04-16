package backend;

class IncludeAll 
{
    public static var allFlixel:Array<Class<Dynamic>> = [];

    static var miniFlixel:Array<Class<Dynamic>> = [
        flixel.FlxBasic, flixel.FlxCamera, flixel.FlxG, flixel.FlxG,
        flixel.FlxObject, flixel.FlxSprite, flixel.FlxState, flixel.FlxStrip, flixel.FlxSubState,
    ];

    static var regularFlixel:Array<Class<Dynamic>> = {
        var array = miniFlixel.copy();
        var array2:Array<Class<Dynamic>> = [
            flixel.effects.FlxFlicker, flixel.graphics.FlxGraphic, flixel.graphics.frames.FlxFramesCollection,
            flixel.group.FlxGroup, flixel.group.FlxGroup.FlxTypedGroup, flixel.math.FlxMath, flixel.sound.FlxSound,
            flixel.text.FlxText, flixel.text.FlxBitmapText, flixel.tweens.FlxTween, flixel.tweens.FlxEase, 
            flixel.ui.FlxBar, flixel.ui.FlxButton, flixel.util.FlxSave, flixel.util.FlxTimer,

            #if ("flixel-addons")
            flixel.addons.text.FlxTypeText, flixel.addons.text.FlxTextField,
            #end
        ];

        for (i in array2)
            array.push(i);

        array;
    }

    static var fullFlixel:Array<Class<Dynamic>> = {
        var array = regularFlixel.copy();
        var array2:Array<Class<Dynamic>> = [
            flixel.animation.FlxAnimation, flixel.animation.FlxAnimationController, flixel.animation.FlxBaseAnimation, flixel.animation.FlxPrerotatedAnimation,
            flixel.effects.particles.FlxEmitter, flixel.effects.particles.FlxParticle, flixel.effects.postprocess.PostProcess,
            flixel.graphics.FlxAsepriteUtil, flixel.graphics.atlas.FlxNode, flixel.graphics.atlas.FlxAtlas,
            flixel.graphics.frames.FlxAtlasFrames, flixel.graphics.frames.FlxBitmapFont, flixel.graphics.frames.FlxFilterFrames,
            flixel.graphics.frames.FlxFrame, flixel.graphics.frames.FlxImageFrame, flixel.graphics.frames.FlxTileFrames,
            flixel.graphics.tile.FlxDrawBaseItem, flixel.graphics.tile.FlxDrawQuadsItem, flixel.graphics.tile.FlxDrawTrianglesItem, flixel.graphics.tile.FlxGraphicsShader,
            flixel.input.FlxBaseKeyList, flixel.input.FlxInput, flixel.input.FlxKeyManager, flixel.input.FlxPointer, flixel.input.FlxSwipe, 
            flixel.input.actions.FlxAction, flixel.input.actions.FlxActionInput, flixel.input.actions.FlxActionInputAnalog, flixel.input.actions.FlxActionInputDigital,
            flixel.input.actions.FlxActionManager, flixel.input.actions.FlxActionSet, flixel.input.actions.FlxSteamController,
            flixel.input.gamepad.FlxGamepad, flixel.input.gamepad.FlxGamepadAnalogStick, flixel.input.gamepad.FlxGamepadButton, flixel.input.gamepad.FlxGamepadManager,
            flixel.input.gamepad.lists.FlxBaseGamepadList, flixel.input.gamepad.lists.FlxGamepadAnalogList, flixel.input.gamepad.lists.FlxGamepadAnalogStateList, flixel.input.gamepad.lists.FlxGamepadAnalogValueList,
            flixel.input.gamepad.lists.FlxGamepadButtonList, flixel.input.gamepad.lists.FlxGamepadMotionValueList, flixel.input.gamepad.lists.FlxGamepadPointerValueList,
            flixel.input.keyboard.FlxKeyList, flixel.input.keyboard.FlxKeyboard,
            flixel.input.mouse.FlxMouse, flixel.input.mouse.FlxMouseButton, flixel.input.mouse.FlxMouseEvent, flixel.input.mouse.FlxMouseEventManager,
            flixel.input.touch.FlxTouch, flixel.input.touch.FlxTouchManager,
            flixel.math.FlxAngle, flixel.math.FlxMatrix, flixel.math.FlxRandom, flixel.math.FlxRect, flixel.math.FlxVelocity,
            flixel.path.FlxPath, flixel.sound.FlxSoundGroup, 
            flixel.system.FlxAssets, flixel.system.FlxBasePreloader, flixel.system.FlxBGSprite, flixel.system.FlxLinkedList, flixel.system.FlxPreloader,
            flixel.system.FlxQuadTree, flixel.system.FlxSplash, flixel.system.FlxVersion,
            flixel.system.scaleModes.BaseScaleMode, flixel.system.scaleModes.FillScaleMode, flixel.system.scaleModes.FixedScaleAdjustSizeScaleMode, flixel.system.scaleModes.FixedScaleMode,
            flixel.system.scaleModes.PixelPerfectScaleMode, flixel.system.scaleModes.RatioScaleMode, flixel.system.scaleModes.RelativeScaleMode, flixel.system.scaleModes.StageSizeScaleMode,
            flixel.system.ui.FlxFocusLostScreen, flixel.system.ui.FlxSoundTray, flixel.system.ui.FlxSystemButton,
            flixel.text.FlxText.FlxTextFormat, flixel.tile.FlxTile, flixel.tile.FlxTileblock, flixel.tile.FlxTilemap, flixel.tile.FlxTilemapBuffer,
            flixel.tweens.misc.AngleTween, flixel.tweens.misc.ColorTween, flixel.tweens.misc.NumTween, flixel.tweens.misc.ShakeTween, flixel.tweens.misc.VarTween,
            flixel.ui.FlxAnalog, flixel.ui.FlxBitmapTextButton, flixel.ui.FlxSpriteButton, flixel.ui.FlxVirtualPad,
            flixel.util.FlxArrayUtil, flixel.util.FlxBitmapDataUtil, flixel.util.FlxCollision, flixel.util.FlxColorTransformUtil,
            flixel.util.FlxDestroyUtil, flixel.util.FlxGradient, flixel.util.FlxPath, flixel.util.FlxPool,
            flixel.util.FlxSort, flixel.util.FlxSpriteUtil, flixel.util.FlxStringUtil, flixel.util.FlxUnicodeUtil, 
            flixel.util.helpers.FlxBounds, flixel.util.helpers.FlxPointRangeBounds, flixel.util.helpers.FlxRange, flixel.util.helpers.FlxRangeBounds,
        
            #if ("flixel-addons")
            flixel.addons.api.FlxGameJolt, flixel.addons.display.FlxBackdrop, flixel.addons.display.FlxExtendedMouseSprite,
            flixel.addons.display.FlxExtendedSprite, flixel.addons.display.FlxGridOverlay, flixel.addons.display.FlxMouseSpring, flixel.addons.display.FlxNestedSprite, flixel.addons.display.FlxPieDial,
            flixel.addons.display.FlxRuntimeShader, flixel.addons.display.FlxShaderMaskCamera, flixel.addons.display.FlxSliceSprite, 
            flixel.addons.display.FlxStarField.FlxStarField2D, flixel.addons.display.FlxStarField.FlxStarField3D, flixel.addons.display.FlxTiledSprite, flixel.addons.display.FlxZoomCamera,
            flixel.addons.display.shapes.FlxShape, flixel.addons.display.shapes.FlxShapeArrow, flixel.addons.display.shapes.FlxShapeBox, flixel.addons.display.shapes.FlxShapeCircle,
            flixel.addons.display.shapes.FlxShapeCross, flixel.addons.display.shapes.FlxShapeDonut, flixel.addons.display.shapes.FlxShapeDoubleCircle, flixel.addons.display.shapes.FlxShapeGrid,
            flixel.addons.display.shapes.FlxShapeLightning, flixel.addons.display.shapes.FlxShapeLine, flixel.addons.display.shapes.FlxShapeSquareDonut,
            flixel.addons.editors.ogmo.FlxOgmoLoader, flixel.addons.editors.ogmo.FlxOgmo3Loader, flixel.addons.editors.pex.FlxPexParser,
            #if spinehaxe flixel.addons.editors.spine.FlxSpine, flixel.addons.editors.spine.FlxSpine.FlxSpineCollider, flixel.addons.editors.spine.texture.FlixelTextureLoader, #end
            flixel.addons.editors.tiled.TiledMap, flixel.addons.editors.tiled.TiledGroupLayer, flixel.addons.editors.tiled.TiledImageLayer, flixel.addons.editors.tiled.TiledImageTile,
            flixel.addons.editors.tiled.TiledLayer, flixel.addons.editors.tiled.TiledObject, flixel.addons.editors.tiled.TiledObjectLayer, flixel.addons.editors.tiled.TiledPropertySet, 
            flixel.addons.editors.tiled.TiledTileLayer, flixel.addons.editors.tiled.TiledTilePropertySet, flixel.addons.editors.tiled.TiledTileSet,
            flixel.addons.effects.FlxClothSprite, flixel.addons.effects.FlxSkewedSprite, flixel.addons.effects.FlxTrail, flixel.addons.effects.FlxTrailArea,
            flixel.addons.effects.chainable.FlxEffectSprite, flixel.addons.effects.chainable.FlxGlitchEffect, flixel.addons.effects.chainable.FlxOutlineEffect, flixel.addons.effects.chainable.FlxRainbowEffect,
            flixel.addons.effects.chainable.FlxShakeEffect, flixel.addons.effects.chainable.FlxTrailEffect, flixel.addons.effects.chainable.FlxWaveEffect,
            flixel.addons.plugin.FlxScrollingText, flixel.addons.plugin.control.FlxControl, flixel.addons.plugin.control.FlxControlHandler,
            flixel.addons.plugin.screengrab.FlxScreenGrab, flixel.addons.plugin.taskManager.FlxTask, flixel.addons.plugin.taskManager.FlxTaskManager,
            flixel.addons.tile.FlxCaveGenerator, flixel.addons.tile.FlxRayCastTilemap, flixel.addons.tile.FlxTileAnimation, flixel.addons.tile.FlxTilemapExt, flixel.addons.tile.FlxTileSpecial,
            flixel.addons.transition.FlxTransitionSprite, flixel.addons.transition.FlxTransitionableState, flixel.addons.transition.Transition, flixel.addons.transition.TransitionData, 
            flixel.addons.transition.TransitionEffect, flixel.addons.transition.TransitionFade, flixel.addons.transition.TransitionTiles, flixel.addons.transition.TransitionTiles,
            flixel.addons.ui.FlxButtonPlus, flixel.addons.ui.FlxClickArea, flixel.addons.ui.FlxSlider,
            flixel.addons.util.FlxAsyncLoop, flixel.addons.util.FlxFSM, flixel.addons.util.FlxScene, flixel.addons.util.FlxSimplex, flixel.addons.util.PNGEncoder,
            flixel.addons.weapon.FlxBullet, flixel.addons.weapon.FlxWeapon, 
            #end

            #if ("flixel-ui")
            flixel.addons.ui.Anchor, flixel.addons.ui.AnchorPoint, flixel.addons.ui.BorderDef, flixel.addons.ui.ButtonLabelStyle, flixel.addons.ui.FlxBaseMultiInput, 
            flixel.addons.ui.FlxInputText, flixel.addons.ui.FlxMultiGamepad, flixel.addons.ui.FlxMultiGamepadAnalogStick, flixel.addons.ui.FlxMultiKey, flixel.addons.ui.FlxUI, flixel.addons.ui.FlxUI9SliceSprite,
            flixel.addons.ui.FlxUIAssets, flixel.addons.ui.FlxUIBar, flixel.addons.ui.FlxUIButton, flixel.addons.ui.FlxUICheckBox, flixel.addons.ui.FlxUIColorSwatch, flixel.addons.ui.FlxUICursor,
            flixel.addons.ui.FlxUIDropDownMenu, flixel.addons.ui.FlxUIGroup, flixel.addons.ui.FlxUIInputText, flixel.addons.ui.FlxUILine, flixel.addons.ui.FlxUIList, flixel.addons.ui.FlxUILoadingScreen, flixel.addons.ui.FlxUIMouse,
            flixel.addons.ui.FlxUINumericStepper, flixel.addons.ui.FlxUIPopup, flixel.addons.ui.FlxUIRadioGroup, flixel.addons.ui.FlxUIRegion, flixel.addons.ui.FlxUISlider, flixel.addons.ui.FlxUISprite, flixel.addons.ui.FlxUISpriteButton, 
            flixel.addons.ui.FlxUIState, flixel.addons.ui.FlxUISubState, flixel.addons.ui.FlxUITabMenu, flixel.addons.ui.FlxUIText, flixel.addons.ui.FlxUITileTest, flixel.addons.ui.FlxUITooltip, flixel.addons.ui.FlxUITooltipManager,
            flixel.addons.ui.FlxUITypedButton, flixel.addons.ui.FontDef, flixel.addons.ui.FontFixer, flixel.addons.ui.StrNameLabel, flixel.addons.ui.SwatchData, flixel.addons.ui.U
            #end
        ];

        for (i in array2)
            array.push(i);

        array;
    }

    public static function init()
    {
        for (i in fullFlixel.copy())
        {
            allFlixel.push(i);
        }
    }
}