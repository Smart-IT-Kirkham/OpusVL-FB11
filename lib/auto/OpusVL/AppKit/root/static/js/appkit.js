// appkit.js
//
// Utility functions for OpusVL::AppKit


//--appNav top navigation menu--------------------------------------------------

var appList = {
  show: function() {
    this.active = true;
    $('#appList').show();
    $('#appKitSearch').hide();
  },
  
  hide: function() {
    this.active = false;    
    $('#appList').hide();
  }  
};

$(function() {
  $('#appList_anchor').mousedown(function() {appList.show();});
  $('#appList_anchor').click(function() {return false;});
  
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
    appList.hover = true;
    clearTimeout(appList.viewTimeout);
  });
  
  $('#appList').mouseout(function() {
    appList.hover = false;
    if (appList.active) {
      clearTimeout(appList.viewTimeout);
      appList.viewTimeout = setTimeout(function(){appList.hide()},1000);
    }
  });
});


//--Search top navigation drop-down menu----------------------------------------

var appKitSearch = {
  show: function() {
    this.active = true;
    $('#appKitSearch').show();
    $('#appList').hide();
  },
  
  hide: function() {
    this.active = false;    
    $('#appKitSearch').hide();
  }  
};

$(function() {
  $('#appKitSearch_anchor').mousedown(function() {appKitSearch.show();});
  $('#appKitSearch_anchor').click(function() {return false;});
  
  $('#appKitSearch_anchor').mouseover(function() {
    appKitSearch.overAnchor = true;
    appKitSearch.anchorMouseoverTimeout = setTimeout(function(){appKitSearch.show()},250);
  });
  
  $('#appKitSearch_anchor').mouseout(function() {
    appKitSearch.overAnchor = false;
    clearTimeout(appKitSearch.anchorMouseoverTimeout);
    if (appKitSearch.active) {
      clearTimeout(appKitSearch.viewTimeout);
      appKitSearch.viewTimeout = setTimeout(function(){appKitSearch.hide()},1000);
    }
  });
  
  $('#appKitSearch').mouseover(function() {
    appKitSearch.hover = true;
    clearTimeout(appKitSearch.viewTimeout);
  });
  
  $('#appKitSearch').mouseout(function() {
    appKitSearch.hover = false;
    if (appKitSearch.active) {
      clearTimeout(appKitSearch.viewTimeout);
      appKitSearch.viewTimeout = setTimeout(function(){appKitSearch.hide()},1000);
    }
  });
});


//--Render any action drop-down controls----------------------------------------

var appKit = {
  windowClick: function() {
    $(".control-edit-small > ul").each(function(){
        $(this).hide();
    });    
  }
};

$(function() {
  $(window).click(function(){appKit.windowClick();
    if (!appList.hover) {
      appList.hide();
    }
    if (!appKitSearch.hover) {
      appKitSearch.hide();
    }
    //$(".control-edit-small > ul").each(function(){
      //if (!$(this).hasClass('nohide')) {
      //  $(this).hide();
      //};
    //});
    //$(".control-edit-small > ul").removeClass('nohide');
  });
    
  $(".control-edit-small").each(function() {
    $('<a href="#"></a>').click(
      function() {
        $(".control-edit-small > ul").each(function(){$(this).hide();});
        var x = $(this).prev();
        if (x.css('display') == 'none') {
          x.show();
          //x.addClass('nohide');
        } else {
          x.hide();
        }
        return false;
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


