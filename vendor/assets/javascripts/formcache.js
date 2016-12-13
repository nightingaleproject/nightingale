/*!
 * Form Cache v@VERSION
 * https://github.com/fengyuanchen/formcache
 *
 * Copyright 2014 Fengyuan Chen
 * Released under the MIT license
 *
 * Date: @DATE
 */

(function (factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as anonymous module.
    define('formcache', ['jquery'], factory);
  } else {
    // Browser globals.
    factory(jQuery);
  }
})(function ($) {

  'use strict';

  var $window = $(window),
      sessionStorage = window.sessionStorage,
      localStorage = window.localStorage,

      // Constants
      STRING_UNDEFINED = 'undefined',
      FORMCACHE_NAMESPACE = '.formcache',

      // Patterns
      REGEXP_CHARACTERS = /[\.\*\+\^\$\:\!\[\]#>~]+/g,

      // Events
      EVENT_CHANGE = 'change' + FORMCACHE_NAMESPACE,
      EVENT_BEFOREUNLOAD = 'beforeunload' + FORMCACHE_NAMESPACE,

      isCheckboxOrRadio = function (input) {
        return input.type === 'checkbox' || input.type === 'radio';
      },

      toNumber = function (n) {
        return parseInt(n, 10);
      },

      // Constructor
      FormCache = function (form, options) {
        this.form = form;
        this.$form = $(form);
        this.defaults = $.extend({}, FormCache.DEFAULTS, $.isPlainObject(options) ? options : {});
        this.init();
      };

  FormCache.prototype = {
    constructor: FormCache,

    init: function () {
      var defaults = this.defaults;

      defaults.maxAge = Math.abs(defaults.maxAge || defaults.maxage);
      defaults.autoStore = Boolean(defaults.autoStore || defaults.autostore);
      this.initKey();
      this.initStorage();
      this.caches = this.storage.caches;
      this.index = 0;
      this.activeIndex = 0;
      this.storing = null;

      if (!$.isArray(defaults.controls)) {
        defaults.controls = [];
      }

      this.$controls = this.$form.find(defaults.controls.join()).not(':file'); // Ignores file inputs

      this.addListeners();
      this.outputCache();
    },

    initKey: function () {
      var $this = this.$form,
          key = this.defaults.key || $this.data('key');

      if (!key) {
        $('form').each(function (i) {
          $(this).data('key', i);
        });

        key = $this.data('key');
      }

      this.key = (location.pathname + '#formcache-' + key);
    },

    initStorage: function () {
      var defaults = this.defaults,
          key = this.key,
          now = new Date(),
          original = {
            date: now,
            maxAge: defaults.maxAge,
            caches: []
          },
          storage;

      if (sessionStorage) {
        storage = sessionStorage.getItem(key);
      }

      if (!storage && localStorage) {
        storage = localStorage.getItem(key);
      }

      storage = typeof storage === 'string' ? JSON.parse(storage) : null;

      if ($.isPlainObject(storage)) {
        if (typeof storage.maxAge === 'number' && ((now - new Date(storage.date)) / 1000) > storage.maxAge) {
          storage = original;
          // this.clear(); // Clears expired storage
        }
      } else {
        storage = original;
      }

      this.storage = storage;
    },

    addListeners: function () {
      if (this.defaults.autoStore) {
        this.$controls.on(EVENT_CHANGE, $.proxy(this.change, this));
        $window.on(EVENT_BEFOREUNLOAD, $.proxy(this.beforeunload, this));
      }
    },

    removeListeners: function () {
      if (this.defaults.autoStore) {
        this.$controls.off(EVENT_CHANGE, this.change);
        $window.off(EVENT_BEFOREUNLOAD, this.beforeunload);
      }
    },

    change: function (e) {
      var input = e.target,
          $this = $(input),
          name = $this.attr('name'),
          value = [],
          tmpName,
          val;

      if (!name) {
        return;
      }

      tmpName = name.replace(REGEXP_CHARACTERS, ''); // Replaces unintended characters

      this.$controls.filter('[name*="' + tmpName + '"]').each(function () {
        if (isCheckboxOrRadio(input)) {
          value.push(this.checked);
        } else {
          val = $(this).val();

          if (val) {
            value.push(val);
          }
        }
      });

      if (value.length) {
        this.update(name, value);

        clearTimeout(this.storing);
        this.storing = setTimeout($.proxy(this.store, this), 1000);
      }
    },

    beforeunload: function () {
      this.update();
      this.store();
    },

    update: function (name, value) {
      var activeIndex = this.activeIndex || this.index,
          cache = this.getCache(activeIndex);

      if (typeof name === 'string') {
        cache[name] = value;
      } else {
        cache = this.serialize();
      }

      this.setCache(activeIndex, cache);
    },

    serialize: function () {
      var cache = {};

      this.$controls.each(function () {
        var $this = $(this),
            name = $this.attr('name'),
            value,
            val;

        if (!name) {
          return;
        }

        value = cache[name];
        value = $.isArray(value) ? value : [];

        if (isCheckboxOrRadio(this)) {
          value.push(this.checked);
        } else {
          val = $this.val();

          if (val) {
            value.push(val);
          }
        }

        if (value.length) {
          cache[name] = value;
        }
      });

      return cache;
    },

    getCache: function (index) {
      return this.caches[(toNumber(index) || this.index)] || {};
    },

    getCaches: function () {
      return this.caches;
    },

    setCache: function (index, data) {
      if (typeof data === STRING_UNDEFINED) {
        data = index;
        index = NaN;
      }

      if ($.isPlainObject(data)) {
        index = toNumber(index) || this.index;
        this.caches[index] = data;
        this.store();
      }
    },

    setCaches: function (data) {
      if ($.isArray(data)) {
        this.caches = data;
        this.store();
      }
    },

    removeCache: function (index) {
      this.caches.splice((toNumber(index) || this.index), 1);
      this.store();
    },

    removeCaches: function () {
      this.caches = [];
      this.store();
    },

    outputCache: function (index) {
      var cache = this.getCache(index);

      if ($.isPlainObject(cache)) {

        this.activeIndex = toNumber(index) || this.index;

        // Clone a new one deeply, avoid to change the original data
        cache = $.extend(true, {}, cache);

        this.$controls.each(function () {
          var $this = $(this),
              name = $this.attr('name'),
              value,
              val;

          if (!name) {
            return;
          }

          value = cache[name];

          if ($.isArray(value) && value.length) {
            val = value.shift();

            if (isCheckboxOrRadio(this)) {
              this.checked = val;
            } else {
              $this.val(val);
            }
          }
        });
      }
    },

    store: function () {
      var storage = this.storage,
          key = this.key,
          defaults = this.defaults;

      storage.date = new Date();
      storage.maxAge = defaults.maxAge;
      storage = JSON.stringify(storage);

      if (defaults.session && sessionStorage) {
        sessionStorage.setItem(key, storage);
      }

      if (defaults.local && localStorage) {
        localStorage.setItem(key, storage);
      }
    },

    clear: function () {
      var key = this.key,
          defaults = this.defaults;

      if (defaults.session && sessionStorage) {
        sessionStorage.removeItem(key);
      }

      if (defaults.local && localStorage) {
        localStorage.removeItem(key);
      }
    },

    destroy: function () {
      this.removeListeners();
      this.$form.removeData('formcache');
    }
  };

  FormCache.DEFAULTS = {
    key: '',
    local: true,
    session: true,
    autoStore: true,
    maxAge: undefined,
    controls: [
      'select',
      'textarea',
      'input'
      // 'input[type="text"]',
      // 'input[type="password"]',
      // 'input[type="datetime"]',
      // 'input[type="checkbox"]',
      // 'input[type="radio"]',
      // 'input[type="datetime-local"]',
      // 'input[type="date"]',
      // 'input[type="month"]',
      // 'input[type="time"]',
      // 'input[type="week"]',
      // 'input[type="number"]',
      // 'input[type="email"]',
      // 'input[type="url"]',
      // 'input[type="search"]',
      // 'input[type="tel"]',
      // 'input[type="color"]'
    ]
  };

  FormCache.setDefaults = function (options) {
    $.extend(FormCache.DEFAULTS, options);
  };

  // Save the other formcache
  FormCache.other = $.fn.formcache;

  // Register as jQuery plugin
  $.fn.formcache = function (options) {
    var args = [].slice.call(arguments, 1),
        result;

    this.each(function () {
      var $this = $(this),
          data = $this.data('formcache'),
          fn;

      if (!data) {
        $this.data('formcache', (data = new FormCache(this, options)));
      }

      if (typeof options === 'string' && $.isFunction((fn = data[options]))) {
        result = fn.apply(data, args);
      }
    });

    return typeof result !== STRING_UNDEFINED ? result : this;
  };

  $.fn.formcache.Constructor = FormCache;
  $.fn.formcache.setDefaults = FormCache.setDefaults;

  // No conflict
  $.fn.formcache.noConflict = function () {
    $.fn.formcache = FormCache.other;
    return this;
  };

  $(function () {
    $('form[data-toggle="formcache"]').formcache();
  });
});
