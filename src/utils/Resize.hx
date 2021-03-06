package src.utils;

import haxe.Timer;
import js.jquery.JQuery;
import js.jquery.Event;
import js.html.Image;
import src.utils.Dom;
import src.utils.UrlParameter;
import tween.TweenMaxHaxe;

class Resize {

    private static var _resizeTimer   : Timer;
    private static var _ratio         : Float;
    private static var _MaxWinHeight  : Int;
    private static var _objStateArray : Map<String,Array<Float>>;
    private static var _jMainboard    : JQuery;
    private static var _jSidemenuLeft : JQuery;
    private static var _jSidemenuRight: JQuery;

    /* =======================================================================
    Init
    ========================================================================== */
    public static function init():Void {

        _MaxWinHeight   = 810;
        _objStateArray  = new Map();
        _jMainboard     = new JQuery('#mainboard');
        _jSidemenuLeft  = new JQuery('#sidemenu-left');
        _jSidemenuRight = new JQuery('#sidemenu-right');
        setObjStateMap();
        
        getWindowRatio();


        Dom.jWindow.on('resize',function(event:Event) {

            // if (_resizeTimer != null) _resizeTimer.stop();
            
            // _resizeTimer     = new Timer(200);
            // _resizeTimer.run = function() {

                getWindowRatio();

                var obj : JQuery = _jMainboard.find('.object');

                for (i in 0 ... obj.length) {

                    resizeDom(obj.eq(i),true);
                    
                }
                
            //     _resizeTimer.stop();

            // };


            if (_resizeTimer != null) _resizeTimer.stop();
            
            _resizeTimer     = new Timer(200);
            _resizeTimer.run = function() {

                getWindowRatio(true);
                var obj : JQuery = _jMainboard.find('.object');

                for (i in 0 ... obj.length) {

                    resizeDom(obj.eq(i),true);
                    
                }
                
                _resizeTimer.stop();

            };

        });

    }

            /* =======================================================================
            Set Obj State
            ========================================================================== */
            private static function setObjStateMap():Void {

                setObjState(_jMainboard);
                setObjState(_jMainboard.find('.board .human'));
                setObjState(_jMainboard.find('.board .chair'));
                setObjState(_jMainboard.find('.board .desk'));
                setObjState(_jMainboard.find('.board .desk .desk-table'));
                setObjState(_jMainboard.find('.board .desk .desk-left'));
                setObjState(_jMainboard.find('.board .desk .desk-right'));
                setObjState(_jSidemenuRight);
                setObjState(_jSidemenuLeft);

            }

            /* =======================================================================
            Set Obj State
            ========================================================================== */
            private static function setObjState(jTarget:JQuery):Void {

                var name  : String     = (jTarget.prop('id')) ? jTarget.prop('id') : jTarget.prop('class');
                var array : Array<Float> = new Array();

                array.push(jTarget.width());
                array.push(jTarget.height());
                array.push(Std.parseInt(jTarget.css('top')));
                array.push(Std.parseInt(jTarget.css('left')));

                _objStateArray.set(name,array);

            }

    /* =======================================================================
    Get Ratio
    ========================================================================== */
    public static function getRatio():Float {

        return _ratio;

    }

    /* =======================================================================
    Set Ratio
    ========================================================================== */
    public static function setRatio():Void {

        var winH : Float = Dom.jWindow.height();
        _ratio = ((100 * winH)/_MaxWinHeight)/100;
        _ratio = (_ratio > 1) ? 0.999 : _ratio;

    }

    /* =======================================================================
    Get Window Ratio
    ========================================================================== */
    public static function getWindowRatio(flag : Bool = false):Void {

        _ratio = 1;

        if (_MaxWinHeight > Dom.jWindow.height() || flag) {

            setRatio();
            resizeDom(_jMainboard,false,true);
            resizeDom(_jMainboard.find('.board .human'),true);
            resizeDom(_jMainboard.find('.board .chair'),true);
            resizeDom(_jMainboard.find('.board .desk'),true);
            resizeDom(_jMainboard.find('.board .desk .desk-table'),true);
            resizeDom(_jMainboard.find('.board .desk .desk-left'),true);
            resizeDom(_jMainboard.find('.board .desk .desk-right'),true);
            var jTrashDiv = new JQuery('#trash').find('div');
            for (i in 0 ... jTrashDiv.length) {

                var jTrashTar : JQuery = jTrashDiv.eq(i);

                resizeDom(jTrashTar,false,true);

                if (jTrashTar.hasClass('trash-bg')) {

                    var bottom : Int = Std.parseInt(jTrashTar.css('bottom'));
                    jTrashTar.css({'bottom': Math.round(bottom * _ratio)});
                    
                }

            }
            
            TweenMaxHaxe.set(_jSidemenuRight,{ scaleX:_ratio, scaleY:_ratio });
            TweenMaxHaxe.set(_jSidemenuLeft,{ scaleX:_ratio, scaleY:_ratio });
            var topR : Int = Std.parseInt(_jSidemenuRight.css('top'));
            var topL : Int = Std.parseInt(_jSidemenuLeft.css('top'));
            _jSidemenuRight.css({'top': Math.round(_objStateArray.get('sidemenu-right')[2] * _ratio)});
            _jSidemenuLeft.css({'top': Math.round(_objStateArray.get('sidemenu-left')[2] * _ratio)});

        }

    }

    /* =======================================================================
    Resize Dom
    ========================================================================== */
    public static function resizeDom(jTarget:JQuery,isPosi:Bool = false,isMLeft:Bool = false):Void {

        if (_ratio == 1) return;

        if (isPosi) {

            var name : String = (jTarget.prop('id')) ? jTarget.prop('id') : jTarget.prop('class');
            var top  : Float = 0;
            var left : Float = 0;

            if (_objStateArray.exists(name)) {

                top  = _objStateArray.get(name)[2];
                left = _objStateArray.get(name)[3];
                
            } else {

                var r  : EReg = ~/[^0-9^\.]/g;
                var id : Int = Std.parseInt(r.replace(name,""));
                top  = UrlParameter.getParamOption(Std.string(id) + "_y");
                left = UrlParameter.getParamOption(Std.string(id) + "_x");

            }

            jTarget.css({

                'top' : top * _ratio,
                'left': left * _ratio

            });

        }

        if (jTarget.hasClass('object')) {

            var img = new Image();
            img.src = jTarget.find('img').prop('src');

            jTarget.find('img').css({

                width : Math.round(img.width * _ratio),
                height: Math.round(img.height * _ratio)
            });

            return;
        }

        if (jTarget.css('background-image') != "none") {

            var img : Image = new Image();
            var a = jTarget.css('background-image');
            var src : String = (a.indexOf('url("') > -1) ? a.split('url("')[1].split('")')[0]: a.split('url(')[1].split(')')[0];
            img.src = src;
            var w : Int = Math.round(img.width * _ratio);
            var h : Int = Math.round(img.height * _ratio);

            jTarget.width(w);
            jTarget.height(h);
            if (isMLeft) jTarget.css({'margin-left': -(w/2)});
            
        }

        if (jTarget.hasClass('trash-bg')) {

            jTarget.width(Math.round(200 * _ratio));
            jTarget.height(Math.round(200 * _ratio));
            jTarget.css({
                "margin-left": -100 * _ratio + "px",
                "bottom"     : -60 * _ratio + "px"
            });
            
        }

    }

}
