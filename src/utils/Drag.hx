package src.utils;

import js.JQuery;
import jp.saken.utils.Dom;
import tween.TweenMaxHaxe;
import tween.easing.Elastic;
import tween.easing.Expo;
import src.utils.Html;
import src.Manager;
import src.view.Trash;
import src.view.mainmenu.Mainmenu;

class Drag {

  private static var _diffX    : Float;
  private static var _diffY    : Float;
  private static var _isGrabbed: Bool;
  private static var _jArea    : JQuery;
  private static var _jAreaObj : JQuery;
  private static var _jMenu    : JQuery;

  public static function init(jArea:JQuery,jAreaObj:JQuery,jMenu:JQuery):Void {

    _isGrabbed = false;
    _jArea     = jArea;
    _jAreaObj  = jAreaObj;
    _jMenu     = jMenu;

    _jMenu.find('.slider').find('li').on({ 'mousedown' : grabList });

    Dom.jWindow.on({

      'mousemove':mousemove,
      'mouseup'  :mouseup

    });

    _jAreaObj.on('mousedown',function(event:JqEvent) {

      grabObject(JQuery.cur,event);

    });

    _jAreaObj.on('mouseover',function(event:JqEvent) {

      showOption(JQuery.cur);

    });

  }

      /* =======================================================================
      Grab
      ========================================================================== */
      private static function grabList(event:JqEvent):Void {

        event.preventDefault();

        var target : JQuery = JQuery.cur;

        if (target.hasClass('drop')) return;

        Manager._DragObj = target.find('.img');
        _isGrabbed = true;
        getDiff(event,target);

        var w : Float = (Manager._DragObj.width() - Manager._DragObj.find('img').width())/2;

        Manager._DragObj.css({

          'top'  : untyped event.clientY - _diffY,
          'left' : untyped event.clientX - _diffX + w

        });

        Manager._DragObj.addClass('grab');

      }

  /* =======================================================================
  Drag Img
  ========================================================================== */
  public static function grabObject(target:JQuery,event:JqEvent):Void {

    event.preventDefault();

    Manager._DragObj = target;

    getDiff(event,Manager._DragObj);

    var h : Int = new JQuery('#header').height();
    var w : Int = _jArea.offset().left;

    Manager._DragObj.css({

      'top'  : untyped event.clientY - _diffY,
      'left' : untyped event.clientX - _diffX

    });

    trace(untyped event.clientX - _diffX);

    Manager._DragObj.addClass('grab');
    _isGrabbed = true;

    Trash.show();

  }

      /* =======================================================================
      Get Diff
      ========================================================================== */
      private static function getDiff(event:Dynamic,target:JQuery):Void {

        _diffY = event.offsetY;
        _diffX = event.offsetX;

      }

      /* =======================================================================
      Mouse Move
      ========================================================================== */
      private static function mousemove(event:JqEvent):Void {

        if (_isGrabbed) {

          Manager._DragObj.css({

            'top'     : untyped event.clientY - _diffY,
            'left'    : untyped event.clientX - _diffX

          });

          Trash.onObj(Manager._DragObj);

        }

      }

      /* =======================================================================
      Mouse Up
      ========================================================================== */
      private static function mouseup(event:JqEvent):Void {

        _isGrabbed = false;

        if (Manager._DragObj == null) return;

        if (Manager._DragObj.hasClass('grab')) {
          
          Trash.leaveObj(Manager._DragObj);

          var h : Int = new JQuery('#header').height();
          var w : Int = _jArea.offset().left;

          trace('kiteru');

          Manager._DragObj.css({

            'top'  : event.pageY - h - _diffY,
            'left' : event.pageX - w - _diffX

          });

          Manager._DragObj.removeClass('grab');

        }

        //if (Manager._DragObj.parent().parent('li').length > 0) {
        if (Manager._DragObj.hasClass('img')) {

          if (_jMenu.find('.current').offset().top > event.pageY) {

            Manager._DragObj.parent().parent('li').addClass('drop');
            createListToObj(Manager._DragObj.parent().parent('li'),event);

            _jAreaObj.unbind('mousedown');
            getObject();

          }
        }

        judgeArea(Manager._DragObj);
        Manager._DragObj = null;

      }

      /* =======================================================================
      Create Img
      ========================================================================== */
      private static function createListToObj(target:JQuery,event:JqEvent):Void {

        var id    : String = target.data('id');
        var type  : String = target.data('type');
        var cat   : String = target.data('cat');
        var icon  : String = target.data('icon');
        var price : String = Std.string(target.data('price'));
        if (price.indexOf(',') > -1) price = price.split(',').join('');
        var length: String = target.find('dl').find('dd.length').text();
        var color : String = Param.getParamOption('color');
        var top   : Float  = event.pageY - new JQuery('#header').height() - _diffY;
        var left  : Float  = event.pageX - _jArea.offset().left - _diffX;

        if (type == "accessory" || type == "clothes") {

          var abs : Array<String> = target.data('abs').split(',');
          top  = Std.parseFloat(abs[0]);
          left = Std.parseFloat(abs[1]);

        }

        if (type == "clothes") {

          Mainmenu.clearDrop(_jAreaObj.filter('.clothes').data('id'));
          _jAreaObj.filter('.clothes').remove();

        }
        
        var html   : String = Html.getObj(id,top,left,type,cat,Std.parseInt(price),length,icon,color);
        var jBoard : JQuery = _jArea.find('.board');

        jBoard.append(html);
        Manager._DragObj = jBoard.find('.object.' + id);

        TweenMaxHaxe.set(Manager._DragObj, {scaleX:1.4, scaleY:1.4});
        TweenMaxHaxe.to(Manager._DragObj, 0.3,{scaleX:1, scaleY:1, ease:Elastic.easeOut,delay:0.1,
          onComplete:function() {

            Manager.resizeDom(jBoard.find('.object.' + id),false);
            
          }
        });

      }

      /* =======================================================================
      Judge Area
      ========================================================================== */
      private static function judgeArea(jTarget:JQuery):Void {

        var top    : String = jTarget.css('top').split('px').join('');
        var left   : String = jTarget.css('left').split('px').join('');
        var t      : Int    = Std.parseInt(top);
        var l      : Int    = Std.parseInt(left);
        var bottom : Int    = t + jTarget.height();
        var right  : Int    = l + jTarget.width();
        var areaB  : Int    = _jArea.height();
        var areaR  : Int    = _jArea.width();

        if (top.indexOf('-') == 0)  t = 0;
        if (left.indexOf('-') == 0) l = 0;
        if (bottom > areaB) t = areaB - jTarget.height();
        if (right > areaR)  l = areaR - jTarget.width();

        if (jTarget.hasClass('accessory') || jTarget.hasClass('clothes')) {

          if (Trash.judgeOnObj(jTarget)) return;
          var abs : Array<String> = absPosition(jTarget);
          t = Std.parseInt(abs[0]);
          l = Std.parseInt(abs[1]);
          
        }

        TweenMaxHaxe.to(jTarget,0.5,{top: t, left : l,delay:0.05,ease:Expo.easeOut});
      
      }

      /* =======================================================================
      Absolute Position
      ========================================================================== */
      private static function absPosition(target:JQuery):Array<String> {

        var id    : String        = target.data('id');
        var data  : Dynamic       = Manager._Data;
        var array : Array<String> = [];

        for (i in 0 ... data.object.length) {

          if (data.object[i].id == Std.string(id)) array = data.object[i].abs;
          
        }

        return array;

      }

  /* =======================================================================
  Get Obj
  ========================================================================== */
  public static function getObject():Void {

    _jAreaObj = _jArea.find('.object');
    _jAreaObj.on('mousedown',function(event:JqEvent) {

      grabObject(JQuery.cur,event);

    });

    _jAreaObj.on('mouseover',function(event:JqEvent) {

      showOption(JQuery.cur);

    });
  }

      /* =======================================================================
      Show Option
      ========================================================================== */
      private static function showOption(target:JQuery):Void {

        var length: String = target.data('length');
        var price : String = target.data('price');
        var html  : String = '<span class="object-data"><span>' + length + '<br>';
        html += price + '円</span></span>';
        target.append(html);

        target.on('mouseleave',function(event:JqEvent) {

          target.find('.object-data').remove();
          target.unbind('mouseleave');

        });

      }

}
