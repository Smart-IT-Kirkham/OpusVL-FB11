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
        //return false;
      }
    ).appendTo($(this));
  });
});


//--Setup form focus classes----------------------------------------------------

$(function(){
  $("input").focus(function() {
    $(this).parent().addClass("has_focus")
  });
  $("input").blur(function() {
    $(this).parent().removeClass("has_focus")
  });
  $("textarea").focus(function() {
    $(this).parent().addClass("has_focus")
  });
  $("textarea").blur(function() {
    $(this).parent().removeClass("has_focus")
  });
});


