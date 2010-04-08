// appkit.js
//
// Utility functions for OpusVL::AppKit


//--appNav top navigation menu--------------------------------------------------

var appList = {
  show: function() {
    this.active = true;
    $('#appList').show();
  },
  
  hide: function() {
    this.active = false;    
    $('#appList').hide();
  }  
};

$(function() {
  $('#appList_anchor').click(function() {
    if (appList.active) {
      appList.hide();
    } else {
      appList.show();
    }    
  });
  
  $('#appList_anchor').mouseover(function() {
    appList.overAnchor = true;
    appList.anchorMouseoverTimeout = setTimeout(function(){appList.show()},250);
  });
  
  $('#appList_anchor').mouseout(function() {
    appList.overAnchor = false;
    clearTimeout(appList.anchorMouseoverTimeout);
    if (appList.active) {
      clearTimeout(appList.viewTimeout);
      appList.viewTimeout = setTimeout(function(){appList.hide()},1000);
    }
  });
  
  $('#appList').mouseover(function() {
    clearTimeout(appList.viewTimeout);
  });
  
  $('#appList').mouseout(function() {
    if (appList.active) {
      clearTimeout(appList.viewTimeout);
      appList.viewTimeout = setTimeout(function(){appList.hide()},1000);
    }
  });
});


//--Render any action drop-down controls----------------------------------------

$(function() {
  $(window).click(function(){
    $(".control-edit-small > ul").each(function(){
      if (!$(this).hasClass('nohide')) {
        $(this).hide();
      };
    });
    $(".control-edit-small > ul").removeClass('nohide');
  });
    
  $(".control-edit-small").each(function() {
    $('<a href="#"></a>').click(
      function() {
        var x = $(this).prev();
        if (x.css('display') == 'none') {
          x.show();
          x.addClass('nohide');
        } else {
          x.hide();
        }
      }
    ).appendTo($(this));
  });
});


//--Setup any "Copy to Clipboard" buttons---------------------------------------

$(function() {
  ZeroClipboard.setMoviePath('/static/ZeroClipboard.swf');
  //var AppKitClip = new ZeroClipboard.Client();
  
  //AppKitClip.addEventListener('onMouseOut', function(clip) {
  //  clip.hide();
  //});
  
  $(".copy_to_clipboard").click(function() {
    return false;
  });
  
  $(".copy_to_clipboard").mouseover(function() {
    //alert('Setting up clipboard');
    var clip = new ZeroClipboard.Client();
    
    clip.addEventListener('onMouseOut', function(myClip) {
      setTimeout(function(){myClip.destroy()},0);
    });
    
    clip.addEventListener('onComplete', function(myClip) {
      setTimeout(function(){myClip.destroy()},0);
    });

    clip.setText($(this).attr('href'));
    clip.glue(this);
  });
  
  $(".copy_to_clipboard").mouseout(function() {
    //alert('Removing clipboard');
    //AppKitClip.destroy();
  });
});