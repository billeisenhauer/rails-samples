(function (a) {
  a.fn.hoverIntent = function (l, j) {
    var m = {
      sensitivity: 7,
      interval: 100,
      timeout: 0
    };
    m = a.extend(m, j ? {
      over: l,
      out: j
    } : l);
    var o, n, h, d;
    var e = function (f) {
      o = f.pageX;
      n = f.pageY
    };
    var c = function (g, f) {
      f.hoverIntent_t = clearTimeout(f.hoverIntent_t);
      if ((Math.abs(h - o) + Math.abs(d - n)) < m.sensitivity) {
        a(f).unbind("mousemove", e);
        f.hoverIntent_s = 1;
        return m.over.apply(f, [g])
      } else {
        h = o;
        d = n;
        f.hoverIntent_t = setTimeout(function () {
          c(g, f)
        },
        m.interval)
      }
    };
    var i = function (g, f) {
      f.hoverIntent_t = clearTimeout(f.hoverIntent_t);
      f.hoverIntent_s = 0;
      return m.out.apply(f, [g])
    };
    var b = function (q) {
      var f = this;
      var g = (q.type == "mouseover" ? q.fromElement : q.toElement) || q.relatedTarget;
      while (g && g != this) {
        try {
          g = g.parentNode
        } catch(q) {
          g = this
        }
      }
      if (g == this) {
        if (a.browser.mozilla) {
          if (q.type == "mouseout") {
            f.mtout = setTimeout(function () {
              k(q, f)
            },
            30)
          } else {
            if (f.mtout) {
              f.mtout = clearTimeout(f.mtout)
            }
          }
        }
        return
      } else {
        if (f.mtout) {
          f.mtout = clearTimeout(f.mtout)
        }
        k(q, f)
      }
    };
    var k = function (p, f) {
      var g = jQuery.extend({},
      p);
      if (f.hoverIntent_t) {
        f.hoverIntent_t = clearTimeout(f.hoverIntent_t)
      }
      if (p.type == "mouseover") {
        h = g.pageX;
        d = g.pageY;
        a(f).bind("mousemove", e);
        if (f.hoverIntent_s != 1) {
          f.hoverIntent_t = setTimeout(function () {
            c(g, f)
          },
          m.interval)
        }
      } else {
        a(f).unbind("mousemove", e);
        if (f.hoverIntent_s == 1) {
          f.hoverIntent_t = setTimeout(function () {
            i(g, f)
          },
          m.timeout)
        }
      }
    };
    return this.mouseover(b).mouseout(b)
  }
})(jQuery);
var showNotice, adminMenu, columns;
(function (a) {
  adminMenu = {
    init: function () {
      a("#gfmenu div.gf-menu-toggle").each(function () {
        if (a(this).siblings(".gf-submenu").length) {
          a(this).click(function () {
            adminMenu.toggle(a(this).siblings(".gf-submenu"))
          })
        } else {
          a(this).hide()
        }
      });
      //this.favorites();
      a("a.separator").click(function () {
        if (a("body").hasClass("folded")) {
          adminMenu.fold(1);
          deleteUserSetting("mfold")
        } else {
          adminMenu.fold();
          setUserSetting("mfold", "f")
        }
        return false
      });
      if (a("body").hasClass("folded")) {
        this.fold()
      }
      this.restoreMenuState()
    },
    restoreMenuState: function () {
      a("#gfmenu li.gf-has-submenu").each(function (c, d) {
        var b = getUserSetting("m" + c);
        if (a(d).hasClass("gf-has-current-submenu")) {
          return true
        }
        if ("o" == b) {
          a(d).addClass("gf-menu-open")
        } else {
          if ("c" == b) {
            a(d).removeClass("gf-menu-open")
          }
        }
      })
    },
    toggle: function (b) {
      b.slideToggle(150, function () {
        b.css("display", "")
      }).parent().toggleClass("gf-menu-open");
      a("#gfmenu li.gf-has-submenu").each(function (d, f) {
        var c = a(f).hasClass("gf-menu-open") ? "o" : "c";
        setUserSetting("m" + d, c)
      });
      return false
    },
    fold: function (b) {
      if (b) {
        a("body").removeClass("folded");
        a("#gfmenu li.gf-has-submenu").unbind()
      } else {
        a("body").addClass("folded");
        a("#gfmenu li.gf-has-submenu").hoverIntent({
          over: function (j) {
            var d, c, g, k, i;
            d = a(this).find(".gf-submenu");
            c = d.parent().offset().top + d.height() + 1;
            g = a("#gfwrap").height();
            k = 60 + c - g;
            i = a(window).height() + a("body").scrollTop() - 15;
            if (i < (c - k)) {
              k = c - i
            }
            if (k > 1) {
              d.css({
                marginTop: "-" + k + "px"
              })
            } else {
              if (d.css("marginTop")) {
                d.css({
                  marginTop: ""
                })
              }
            }
            d.addClass("sub-open")
          },
          out: function () {
            a(this).find(".gf-submenu").removeClass("sub-open").css({
              marginTop: ""
            })
          },
          timeout: 220,
          sensitivity: 8,
          interval: 100
        })
      }
    }
  };
  a(document).ready(function () {
    adminMenu.init()
  });
  columns = {
    init: function () {
      a(".hide-column-tog").click(function () {
        var c = a(this).val(),
          b = a(this).attr("checked");
        if (b) {
          a(".column-" + c).show()
        } else {
          a(".column-" + c).hide()
        }
        columns.save_manage_columns_state()
      })
    },
    save_manage_columns_state: function () {
      var b = a(".manage-column").filter(":hidden").map(function () {
        return this.id
      }).get().join(",");
      a.post(ajaxurl, {
        action: "hidden-columns",
        hidden: b,
        screenoptionnonce: a("#screenoptionnonce").val(),
        page: pagenow
      })
    }
  };
  a(document).ready(function () {
    columns.init()
  })
})(jQuery);
showNotice = {
  warn: function () {
    var a = commonL10n.warnDelete || "";
    if (confirm(a)) {
      return true
    }
    return false
  },
  note: function (a) {
    alert(a)
  }
};
jQuery(document).ready(function (d) {
  var f = false,
    a, e, c, b;
  d(".fade").animate({
    backgroundColor: "#ffffe0"
  },
  300).animate({
    backgroundColor: "#fffbcc"
  },
  300).animate({
    backgroundColor: "#ffffe0"
  },
  300).animate({
    backgroundColor: "#fffbcc"
  },
  300);
  d("div.wrap h2 ~ div.updated, div.wrap h2 ~ div.error").addClass("below-h2");
  d("div.updated, div.error").not(".below-h2").insertAfter("div.wrap h2:first");
  d("#doaction, #doaction2").click(function () {
    if (d('select[name="action"]').val() == "delete" || d('select[name="action2"]').val() == "delete") {
      return showNotice.warn()
    }
  });
  d("#show-settings-link").click(function () {
    if (!d("#screen-options-wrap").hasClass("screen-options-open")) {
      d("#contextual-help-link-wrap").css("visibility", "hidden")
    }
    d("#screen-options-wrap").slideToggle("fast", function () {
      if (d(this).hasClass("screen-options-open")) {
        d("#show-settings-link").css({
          backgroundImage: 'url("/images/screen-options-right.gif")'
        });
        d("#contextual-help-link-wrap").css("visibility", "");
        d(this).removeClass("screen-options-open")
      } else {
        d("#show-settings-link").css({
          backgroundImage: 'url("/images/screen-options-right-up.gif")'
        });
        d(this).addClass("screen-options-open")
      }
    });
    return false
  });
  d("#contextual-help-link").click(function () {
    if (!d("#contextual-help-wrap").hasClass("contextual-help-open")) {
      d("#screen-options-link-wrap").css("visibility", "hidden")
    }
    d("#contextual-help-wrap").slideToggle("fast", function () {
      if (d(this).hasClass("contextual-help-open")) {
        d("#contextual-help-link").css({
          backgroundImage: 'url("/images/screen-options-right.gif")'
        });
        d("#screen-options-link-wrap").css("visibility", "");
        d(this).removeClass("contextual-help-open")
      } else {
        d("#contextual-help-link").css({
          backgroundImage: 'url("/images/screen-options-right-up.gif")'
        });
        d(this).addClass("contextual-help-open")
      }
    });
    return false
  });
  d("#contextual-help-link-wrap, #screen-options-link-wrap").show();
  d("table:visible tbody .check-column :checkbox").click(function (g) {
    if ("undefined" == g.shiftKey) {
      return true
    }
    if (g.shiftKey) {
      if (!f) {
        return true
      }
      a = d(f).parents("form:first").find(":checkbox");
      e = a.index(f);
      c = a.index(this);
      b = d(this).attr("checked");
      if (0 < e && 0 < c && e != c) {
        a.slice(e, c).attr("checked", function () {
          if (d(this).parents("tr").is(":visible")) {
            return b ? "checked" : ""
          }
          return ""
        })
      }
    }
    f = this;
    return true
  });
  d("thead :checkbox, tfoot :checkbox").click(function (i) {
    var j = d(this).attr("checked"),
      h = "undefined" == typeof toggleWithKeyboard ? false : toggleWithKeyboard,
    g = i.shiftKey || h;
    d(this).parents("form:first").find("table tbody:visible").find(".check-column :checkbox").attr("checked", function () {
      if (d(this).parents("tr").is(":hidden")) {
        return ""
      }
      if (g) {
        return d(this).attr("checked") ? "" : "checked"
      } else {
        if (j) {
          return "checked"
        }
      }
      return ""
    });
    d(this).parents("form:first").find("table thead:visible, table tfoot:visible").find(".check-column :checkbox").attr("checked", function () {
      if (g) {
        return ""
      } else {
        if (j) {
          return "checked"
        }
      }
      return ""
    })
  });
  d("#default-password-nag-no").click(function () {
    setUserSetting("default_password_nag", "hide");
    d("div.default-password-nag").hide();
    return false
  })
});
(function (d) {
  d.each(["backgroundColor", "borderBottomColor", "borderLeftColor", "borderRightColor", "borderTopColor", "color", "outlineColor"], function (f, e) {
    d.fx.step[e] = function (g) {
      if (g.state == 0) {
        g.start = c(g.elem, e);
        g.end = b(g.end)
      }
      g.elem.style[e] = "rgb(" + [Math.max(Math.min(parseInt((g.pos * (g.end[0] - g.start[0])) + g.start[0]), 255), 0), Math.max(Math.min(parseInt((g.pos * (g.end[1] - g.start[1])) + g.start[1]), 255), 0), Math.max(Math.min(parseInt((g.pos * (g.end[2] - g.start[2])) + g.start[2]), 255), 0)].join(",") + ")"
    }
  });

  function b(f) {
    var e;
    if (f && f.constructor == Array && f.length == 3) {
      return f
    }
    if (e = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(f)) {
      return [parseInt(e[1]), parseInt(e[2]), parseInt(e[3])]
    }
    if (e = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(f)) {
      return [parseFloat(e[1]) * 2.55, parseFloat(e[2]) * 2.55, parseFloat(e[3]) * 2.55]
    }
    if (e = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(f)) {
      return [parseInt(e[1], 16), parseInt(e[2], 16), parseInt(e[3], 16)]
    }
    if (e = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(f)) {
      return [parseInt(e[1] + e[1], 16), parseInt(e[2] + e[2], 16), parseInt(e[3] + e[3], 16)]
    }
    if (e = /rgba\(0, 0, 0, 0\)/.exec(f)) {
      return a.transparent
    }
    return a[d.trim(f).toLowerCase()]
  }

  function c(g, e) {
    var f;
    do {
      f = d.curCSS(g, e);
      if (f != "" && f != "transparent" || d.nodeName(g, "body")) {
        break
      }
      e = "backgroundColor"
    } while (g = g.parentNode);
    return b(f)
  }
  var a = {
    aqua: [0, 255, 255],
    azure: [240, 255, 255],
    beige: [245, 245, 220],
    black: [0, 0, 0],
    blue: [0, 0, 255],
    brown: [165, 42, 42],
    cyan: [0, 255, 255],
    darkblue: [0, 0, 139],
    darkcyan: [0, 139, 139],
    darkgrey: [169, 169, 169],
    darkgreen: [0, 100, 0],
    darkkhaki: [189, 183, 107],
    darkmagenta: [139, 0, 139],
    darkolivegreen: [85, 107, 47],
    darkorange: [255, 140, 0],
    darkorchid: [153, 50, 204],
    darkred: [139, 0, 0],
    darksalmon: [233, 150, 122],
    darkviolet: [148, 0, 211],
    fuchsia: [255, 0, 255],
    gold: [255, 215, 0],
    green: [0, 128, 0],
    indigo: [75, 0, 130],
    khaki: [240, 230, 140],
    lightblue: [173, 216, 230],
    lightcyan: [224, 255, 255],
    lightgreen: [144, 238, 144],
    lightgrey: [211, 211, 211],
    lightpink: [255, 182, 193],
    lightyellow: [255, 255, 224],
    lime: [0, 255, 0],
    magenta: [255, 0, 255],
    maroon: [128, 0, 0],
    navy: [0, 0, 128],
    olive: [128, 128, 0],
    orange: [255, 165, 0],
    pink: [255, 192, 203],
    purple: [128, 0, 128],
    violet: [128, 0, 128],
    red: [255, 0, 0],
    silver: [192, 192, 192],
    white: [255, 255, 255],
    yellow: [255, 255, 0],
    transparent: [255, 255, 255]
  }
})(jQuery);