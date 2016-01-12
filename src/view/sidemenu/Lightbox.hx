package src.view.sidemenu;

import js.JQuery;
import tween.TweenMaxHaxe;
import tween.easing.Elastic;
import tween.easing.Sine;
import tween.easing.Back;

class Lightbox extends Sidemenu {

  private static var _jLightBox : JQuery;

  public function new():Void {

    super();

  }

  /* =======================================================================
  init
  ========================================================================== */
  public static function init(jLightBox:JQuery):Void {

    _jLightBox = jLightBox;

  }

  /* =======================================================================
  Show
  ========================================================================== */
  public static function show(cls:String,jBtn:JQuery):Void {

    var jbox : JQuery = _jLightBox.find('.' + cls);
    var sPEED: Int    = 300;

    jbox.width(50);
    _jLightBox.fadeIn(sPEED,function() {

      jbox.show();
      TweenMaxHaxe.to(jbox, 1, { width : 300 , ease:Elastic.easeOut});
      // jbox.animate({
      //   width: '300px'
      // });

    });

    jbox.find('.close-btn').on('mousedown',function(event:JqEvent) {

      jbox.fadeOut(sPEED);
      _jLightBox.fadeOut(sPEED);

      untyped jbox.find('.close-btn').off('mousedown');

    });

  }

}