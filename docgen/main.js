/*! For license information please see main.js.LICENSE.txt */
;(() => {
  var e = {
      837: (e, t, n) => {
        'use strict'
        n.r(t), n.d(t, { default: () => o })
        var a = n(601),
          i = n.n(a),
          r = n(314),
          s = n.n(r)()(i())
        s.push([
          e.id,
          '@import url(https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@400;500;600;700&display=swap);',
        ]),
          s.push([e.id, "\nhtml,\nbody {\n  font-family: 'Source Code Pro', monospace;\n}\n", ''])
        const o = s
      },
      314: (e) => {
        'use strict'
        e.exports = function (e) {
          var t = []
          return (
            (t.toString = function () {
              return this.map(function (t) {
                var n = '',
                  a = void 0 !== t[5]
                return (
                  t[4] && (n += '@supports ('.concat(t[4], ') {')),
                  t[2] && (n += '@media '.concat(t[2], ' {')),
                  a && (n += '@layer'.concat(t[5].length > 0 ? ' '.concat(t[5]) : '', ' {')),
                  (n += e(t)),
                  a && (n += '}'),
                  t[2] && (n += '}'),
                  t[4] && (n += '}'),
                  n
                )
              }).join('')
            }),
            (t.i = function (e, n, a, i, r) {
              'string' == typeof e && (e = [[null, e, void 0]])
              var s = {}
              if (a)
                for (var o = 0; o < this.length; o++) {
                  var u = this[o][0]
                  null != u && (s[u] = !0)
                }
              for (var p = 0; p < e.length; p++) {
                var l = [].concat(e[p])
                ;(a && s[l[0]]) ||
                  (void 0 !== r &&
                    (void 0 === l[5] ||
                      (l[1] = '@layer'.concat(l[5].length > 0 ? ' '.concat(l[5]) : '', ' {').concat(l[1], '}')),
                    (l[5] = r)),
                  n && (l[2] ? ((l[1] = '@media '.concat(l[2], ' {').concat(l[1], '}')), (l[2] = n)) : (l[2] = n)),
                  i &&
                    (l[4]
                      ? ((l[1] = '@supports ('.concat(l[4], ') {').concat(l[1], '}')), (l[4] = i))
                      : (l[4] = ''.concat(i))),
                  t.push(l))
              }
            }),
            t
          )
        }
      },
      601: (e) => {
        'use strict'
        e.exports = function (e) {
          return e[1]
        }
      },
      884: (e, t, n) => {
        var a = n(837)
        a.__esModule && (a = a.default),
          'string' == typeof a && (a = [[e.id, a, '']]),
          a.locals && (e.exports = a.locals),
          (0, n(534).A)('2cbbc963', a, !1, {})
      },
      534: (e, t, n) => {
        'use strict'
        function a(e, t) {
          for (var n = [], a = {}, i = 0; i < t.length; i++) {
            var r = t[i],
              s = r[0],
              o = { id: e + ':' + i, css: r[1], media: r[2], sourceMap: r[3] }
            a[s] ? a[s].parts.push(o) : n.push((a[s] = { id: s, parts: [o] }))
          }
          return n
        }
        n.d(t, { A: () => f })
        var i = 'undefined' != typeof document
        if ('undefined' != typeof DEBUG && DEBUG && !i)
          throw new Error(
            "vue-style-loader cannot be used in a non-browser environment. Use { target: 'node' } in your Webpack config to indicate a server-rendering environment."
          )
        var r = {},
          s = i && (document.head || document.getElementsByTagName('head')[0]),
          o = null,
          u = 0,
          p = !1,
          l = function () {},
          d = null,
          c = 'data-vue-ssr-id',
          y = 'undefined' != typeof navigator && /msie [6-9]\b/.test(navigator.userAgent.toLowerCase())
        function f(e, t, n, i) {
          ;(p = n), (d = i || {})
          var s = a(e, t)
          return (
            m(s),
            function (t) {
              for (var n = [], i = 0; i < s.length; i++) {
                var o = s[i]
                ;(u = r[o.id]).refs--, n.push(u)
              }
              for (t ? m((s = a(e, t))) : (s = []), i = 0; i < n.length; i++) {
                var u
                if (0 === (u = n[i]).refs) {
                  for (var p = 0; p < u.parts.length; p++) u.parts[p]()
                  delete r[u.id]
                }
              }
            }
          )
        }
        function m(e) {
          for (var t = 0; t < e.length; t++) {
            var n = e[t],
              a = r[n.id]
            if (a) {
              a.refs++
              for (var i = 0; i < a.parts.length; i++) a.parts[i](n.parts[i])
              for (; i < n.parts.length; i++) a.parts.push(v(n.parts[i]))
              a.parts.length > n.parts.length && (a.parts.length = n.parts.length)
            } else {
              var s = []
              for (i = 0; i < n.parts.length; i++) s.push(v(n.parts[i]))
              r[n.id] = { id: n.id, refs: 1, parts: s }
            }
          }
        }
        function h() {
          var e = document.createElement('style')
          return (e.type = 'text/css'), s.appendChild(e), e
        }
        function v(e) {
          var t,
            n,
            a = document.querySelector('style[' + c + '~="' + e.id + '"]')
          if (a) {
            if (p) return l
            a.parentNode.removeChild(a)
          }
          if (y) {
            var i = u++
            ;(a = o || (o = h())), (t = g.bind(null, a, i, !1)), (n = g.bind(null, a, i, !0))
          } else
            (a = h()),
              (t = w.bind(null, a)),
              (n = function () {
                a.parentNode.removeChild(a)
              })
          return (
            t(e),
            function (a) {
              if (a) {
                if (a.css === e.css && a.media === e.media && a.sourceMap === e.sourceMap) return
                t((e = a))
              } else n()
            }
          )
        }
        var T,
          b =
            ((T = []),
            function (e, t) {
              return (T[e] = t), T.filter(Boolean).join('\n')
            })
        function g(e, t, n, a) {
          var i = n ? '' : a.css
          if (e.styleSheet) e.styleSheet.cssText = b(t, i)
          else {
            var r = document.createTextNode(i),
              s = e.childNodes
            s[t] && e.removeChild(s[t]), s.length ? e.insertBefore(r, s[t]) : e.appendChild(r)
          }
        }
        function w(e, t) {
          var n = t.css,
            a = t.media,
            i = t.sourceMap
          if (
            (a && e.setAttribute('media', a),
            d.ssrId && e.setAttribute(c, t.id),
            i &&
              ((n += '\n/*# sourceURL=' + i.sources[0] + ' */'),
              (n +=
                '\n/*# sourceMappingURL=data:application/json;base64,' +
                btoa(unescape(encodeURIComponent(JSON.stringify(i)))) +
                ' */')),
            e.styleSheet)
          )
            e.styleSheet.cssText = n
          else {
            for (; e.firstChild; ) e.removeChild(e.firstChild)
            e.appendChild(document.createTextNode(n))
          }
        }
      },
    },
    t = {}
  function n(a) {
    var i = t[a]
    if (void 0 !== i) return i.exports
    var r = (t[a] = { id: a, exports: {} })
    return e[a](r, r.exports, n), r.exports
  }
  ;(n.n = (e) => {
    var t = e && e.__esModule ? () => e.default : () => e
    return n.d(t, { a: t }), t
  }),
    (n.d = (e, t) => {
      for (var a in t) n.o(t, a) && !n.o(e, a) && Object.defineProperty(e, a, { enumerable: !0, get: t[a] })
    }),
    (n.g = (function () {
      if ('object' == typeof globalThis) return globalThis
      try {
        return this || new Function('return this')()
      } catch (e) {
        if ('object' == typeof window) return window
      }
    })()),
    (n.o = (e, t) => Object.prototype.hasOwnProperty.call(e, t)),
    (n.r = (e) => {
      'undefined' != typeof Symbol &&
        Symbol.toStringTag &&
        Object.defineProperty(e, Symbol.toStringTag, { value: 'Module' }),
        Object.defineProperty(e, '__esModule', { value: !0 })
    }),
    (() => {
      'use strict'
      var e = Object.freeze({}),
        t = Array.isArray
      function a(e) {
        return null == e
      }
      function i(e) {
        return null != e
      }
      function r(e) {
        return !0 === e
      }
      function s(e) {
        return 'string' == typeof e || 'number' == typeof e || 'symbol' == typeof e || 'boolean' == typeof e
      }
      function o(e) {
        return 'function' == typeof e
      }
      function u(e) {
        return null !== e && 'object' == typeof e
      }
      var p = Object.prototype.toString
      function l(e) {
        return '[object Object]' === p.call(e)
      }
      function d(e) {
        var t = parseFloat(String(e))
        return t >= 0 && Math.floor(t) === t && isFinite(e)
      }
      function c(e) {
        return i(e) && 'function' == typeof e.then && 'function' == typeof e.catch
      }
      function y(e) {
        return null == e ? '' : Array.isArray(e) || (l(e) && e.toString === p) ? JSON.stringify(e, f, 2) : String(e)
      }
      function f(e, t) {
        return t && t.__v_isRef ? t.value : t
      }
      function m(e) {
        var t = parseFloat(e)
        return isNaN(t) ? e : t
      }
      function h(e, t) {
        for (var n = Object.create(null), a = e.split(','), i = 0; i < a.length; i++) n[a[i]] = !0
        return t
          ? function (e) {
              return n[e.toLowerCase()]
            }
          : function (e) {
              return n[e]
            }
      }
      var v = h('slot,component', !0),
        T = h('key,ref,slot,slot-scope,is')
      function b(e, t) {
        var n = e.length
        if (n) {
          if (t === e[n - 1]) return void (e.length = n - 1)
          var a = e.indexOf(t)
          if (a > -1) return e.splice(a, 1)
        }
      }
      var g = Object.prototype.hasOwnProperty
      function w(e, t) {
        return g.call(e, t)
      }
      function _(e) {
        var t = Object.create(null)
        return function (n) {
          return t[n] || (t[n] = e(n))
        }
      }
      var k = /-(\w)/g,
        A = _(function (e) {
          return e.replace(k, function (e, t) {
            return t ? t.toUpperCase() : ''
          })
        }),
        M = _(function (e) {
          return e.charAt(0).toUpperCase() + e.slice(1)
        }),
        C = /\B([A-Z])/g,
        S = _(function (e) {
          return e.replace(C, '-$1').toLowerCase()
        }),
        x = Function.prototype.bind
          ? function (e, t) {
              return e.bind(t)
            }
          : function (e, t) {
              function n(n) {
                var a = arguments.length
                return a ? (a > 1 ? e.apply(t, arguments) : e.call(t, n)) : e.call(t)
              }
              return (n._length = e.length), n
            }
      function R(e, t) {
        t = t || 0
        for (var n = e.length - t, a = new Array(n); n--; ) a[n] = e[n + t]
        return a
      }
      function O(e, t) {
        for (var n in t) e[n] = t[n]
        return e
      }
      function E(e) {
        for (var t = {}, n = 0; n < e.length; n++) e[n] && O(t, e[n])
        return t
      }
      function I(e, t, n) {}
      var P = function (e, t, n) {
          return !1
        },
        B = function (e) {
          return e
        }
      function U(e, t) {
        if (e === t) return !0
        var n = u(e),
          a = u(t)
        if (!n || !a) return !n && !a && String(e) === String(t)
        try {
          var i = Array.isArray(e),
            r = Array.isArray(t)
          if (i && r)
            return (
              e.length === t.length &&
              e.every(function (e, n) {
                return U(e, t[n])
              })
            )
          if (e instanceof Date && t instanceof Date) return e.getTime() === t.getTime()
          if (i || r) return !1
          var s = Object.keys(e),
            o = Object.keys(t)
          return (
            s.length === o.length &&
            s.every(function (n) {
              return U(e[n], t[n])
            })
          )
        } catch (e) {
          return !1
        }
      }
      function $(e, t) {
        for (var n = 0; n < e.length; n++) if (U(e[n], t)) return n
        return -1
      }
      function D(e) {
        var t = !1
        return function () {
          t || ((t = !0), e.apply(this, arguments))
        }
      }
      var V = 'data-server-rendered',
        N = ['component', 'directive', 'filter'],
        j = [
          'beforeCreate',
          'created',
          'beforeMount',
          'mounted',
          'beforeUpdate',
          'updated',
          'beforeDestroy',
          'destroyed',
          'activated',
          'deactivated',
          'errorCaptured',
          'serverPrefetch',
          'renderTracked',
          'renderTriggered',
        ],
        F = {
          optionMergeStrategies: Object.create(null),
          silent: !1,
          productionTip: !1,
          devtools: !1,
          performance: !1,
          errorHandler: null,
          warnHandler: null,
          ignoredElements: [],
          keyCodes: Object.create(null),
          isReservedTag: P,
          isReservedAttr: P,
          isUnknownElement: P,
          getTagNamespace: I,
          parsePlatformTagName: B,
          mustUseProp: P,
          async: !0,
          _lifecycleHooks: j,
        },
        W =
          /a-zA-Z\u00B7\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u037D\u037F-\u1FFF\u200C-\u200D\u203F-\u2040\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD/
      function L(e) {
        var t = (e + '').charCodeAt(0)
        return 36 === t || 95 === t
      }
      function q(e, t, n, a) {
        Object.defineProperty(e, t, { value: n, enumerable: !!a, writable: !0, configurable: !0 })
      }
      var z = new RegExp('[^'.concat(W.source, '.$_\\d]')),
        H = '__proto__' in {},
        G = 'undefined' != typeof window,
        K = G && window.navigator.userAgent.toLowerCase(),
        J = K && /msie|trident/.test(K),
        X = K && K.indexOf('msie 9.0') > 0,
        Y = K && K.indexOf('edge/') > 0
      K && K.indexOf('android')
      var Z = K && /iphone|ipad|ipod|ios/.test(K)
      K && /chrome\/\d+/.test(K), K && /phantomjs/.test(K)
      var Q,
        ee = K && K.match(/firefox\/(\d+)/),
        te = {}.watch,
        ne = !1
      if (G)
        try {
          var ae = {}
          Object.defineProperty(ae, 'passive', {
            get: function () {
              ne = !0
            },
          }),
            window.addEventListener('test-passive', null, ae)
        } catch (e) {}
      var ie = function () {
          return void 0 === Q && (Q = !G && void 0 !== n.g && n.g.process && 'server' === n.g.process.env.VUE_ENV), Q
        },
        re = G && window.__VUE_DEVTOOLS_GLOBAL_HOOK__
      function se(e) {
        return 'function' == typeof e && /native code/.test(e.toString())
      }
      var oe,
        ue = 'undefined' != typeof Symbol && se(Symbol) && 'undefined' != typeof Reflect && se(Reflect.ownKeys)
      oe =
        'undefined' != typeof Set && se(Set)
          ? Set
          : (function () {
              function e() {
                this.set = Object.create(null)
              }
              return (
                (e.prototype.has = function (e) {
                  return !0 === this.set[e]
                }),
                (e.prototype.add = function (e) {
                  this.set[e] = !0
                }),
                (e.prototype.clear = function () {
                  this.set = Object.create(null)
                }),
                e
              )
            })()
      var pe = null
      function le(e) {
        void 0 === e && (e = null), e || (pe && pe._scope.off()), (pe = e), e && e._scope.on()
      }
      var de = (function () {
          function e(e, t, n, a, i, r, s, o) {
            ;(this.tag = e),
              (this.data = t),
              (this.children = n),
              (this.text = a),
              (this.elm = i),
              (this.ns = void 0),
              (this.context = r),
              (this.fnContext = void 0),
              (this.fnOptions = void 0),
              (this.fnScopeId = void 0),
              (this.key = t && t.key),
              (this.componentOptions = s),
              (this.componentInstance = void 0),
              (this.parent = void 0),
              (this.raw = !1),
              (this.isStatic = !1),
              (this.isRootInsert = !0),
              (this.isComment = !1),
              (this.isCloned = !1),
              (this.isOnce = !1),
              (this.asyncFactory = o),
              (this.asyncMeta = void 0),
              (this.isAsyncPlaceholder = !1)
          }
          return (
            Object.defineProperty(e.prototype, 'child', {
              get: function () {
                return this.componentInstance
              },
              enumerable: !1,
              configurable: !0,
            }),
            e
          )
        })(),
        ce = function (e) {
          void 0 === e && (e = '')
          var t = new de()
          return (t.text = e), (t.isComment = !0), t
        }
      function ye(e) {
        return new de(void 0, void 0, void 0, String(e))
      }
      function fe(e) {
        var t = new de(
          e.tag,
          e.data,
          e.children && e.children.slice(),
          e.text,
          e.elm,
          e.context,
          e.componentOptions,
          e.asyncFactory
        )
        return (
          (t.ns = e.ns),
          (t.isStatic = e.isStatic),
          (t.key = e.key),
          (t.isComment = e.isComment),
          (t.fnContext = e.fnContext),
          (t.fnOptions = e.fnOptions),
          (t.fnScopeId = e.fnScopeId),
          (t.asyncMeta = e.asyncMeta),
          (t.isCloned = !0),
          t
        )
      }
      'function' == typeof SuppressedError && SuppressedError
      var me = 0,
        he = [],
        ve = function () {
          for (var e = 0; e < he.length; e++) {
            var t = he[e]
            ;(t.subs = t.subs.filter(function (e) {
              return e
            })),
              (t._pending = !1)
          }
          he.length = 0
        },
        Te = (function () {
          function e() {
            ;(this._pending = !1), (this.id = me++), (this.subs = [])
          }
          return (
            (e.prototype.addSub = function (e) {
              this.subs.push(e)
            }),
            (e.prototype.removeSub = function (e) {
              ;(this.subs[this.subs.indexOf(e)] = null), this._pending || ((this._pending = !0), he.push(this))
            }),
            (e.prototype.depend = function (t) {
              e.target && e.target.addDep(this)
            }),
            (e.prototype.notify = function (e) {
              for (
                var t = this.subs.filter(function (e) {
                    return e
                  }),
                  n = 0,
                  a = t.length;
                n < a;
                n++
              )
                t[n].update()
            }),
            e
          )
        })()
      Te.target = null
      var be = []
      function ge(e) {
        be.push(e), (Te.target = e)
      }
      function we() {
        be.pop(), (Te.target = be[be.length - 1])
      }
      var _e = Array.prototype,
        ke = Object.create(_e)
      ;['push', 'pop', 'shift', 'unshift', 'splice', 'sort', 'reverse'].forEach(function (e) {
        var t = _e[e]
        q(ke, e, function () {
          for (var n = [], a = 0; a < arguments.length; a++) n[a] = arguments[a]
          var i,
            r = t.apply(this, n),
            s = this.__ob__
          switch (e) {
            case 'push':
            case 'unshift':
              i = n
              break
            case 'splice':
              i = n.slice(2)
          }
          return i && s.observeArray(i), s.dep.notify(), r
        })
      })
      var Ae = Object.getOwnPropertyNames(ke),
        Me = {},
        Ce = !0
      function Se(e) {
        Ce = e
      }
      var xe = { notify: I, depend: I, addSub: I, removeSub: I },
        Re = (function () {
          function e(e, n, a) {
            if (
              (void 0 === n && (n = !1),
              void 0 === a && (a = !1),
              (this.value = e),
              (this.shallow = n),
              (this.mock = a),
              (this.dep = a ? xe : new Te()),
              (this.vmCount = 0),
              q(e, '__ob__', this),
              t(e))
            ) {
              if (!a)
                if (H) e.__proto__ = ke
                else for (var i = 0, r = Ae.length; i < r; i++) q(e, (o = Ae[i]), ke[o])
              n || this.observeArray(e)
            } else {
              var s = Object.keys(e)
              for (i = 0; i < s.length; i++) {
                var o
                Ee(e, (o = s[i]), Me, void 0, n, a)
              }
            }
          }
          return (
            (e.prototype.observeArray = function (e) {
              for (var t = 0, n = e.length; t < n; t++) Oe(e[t], !1, this.mock)
            }),
            e
          )
        })()
      function Oe(e, n, a) {
        return e && w(e, '__ob__') && e.__ob__ instanceof Re
          ? e.__ob__
          : !Ce || (!a && ie()) || (!t(e) && !l(e)) || !Object.isExtensible(e) || e.__v_skip || De(e) || e instanceof de
          ? void 0
          : new Re(e, n, a)
      }
      function Ee(e, n, a, i, r, s, o) {
        void 0 === o && (o = !1)
        var u = new Te(),
          p = Object.getOwnPropertyDescriptor(e, n)
        if (!p || !1 !== p.configurable) {
          var l = p && p.get,
            d = p && p.set
          ;(l && !d) || (a !== Me && 2 !== arguments.length) || (a = e[n])
          var c = r ? a && a.__ob__ : Oe(a, !1, s)
          return (
            Object.defineProperty(e, n, {
              enumerable: !0,
              configurable: !0,
              get: function () {
                var n = l ? l.call(e) : a
                return Te.target && (u.depend(), c && (c.dep.depend(), t(n) && Be(n))), De(n) && !r ? n.value : n
              },
              set: function (t) {
                var n,
                  i,
                  o = l ? l.call(e) : a
                if ((n = o) === (i = t) ? 0 === n && 1 / n != 1 / i : n == n || i == i) {
                  if (d) d.call(e, t)
                  else {
                    if (l) return
                    if (!r && De(o) && !De(t)) return void (o.value = t)
                    a = t
                  }
                  ;(c = r ? t && t.__ob__ : Oe(t, !1, s)), u.notify()
                }
              },
            }),
            u
          )
        }
      }
      function Ie(e, n, a) {
        if (!$e(e)) {
          var i = e.__ob__
          return t(e) && d(n)
            ? ((e.length = Math.max(e.length, n)), e.splice(n, 1, a), i && !i.shallow && i.mock && Oe(a, !1, !0), a)
            : n in e && !(n in Object.prototype)
            ? ((e[n] = a), a)
            : e._isVue || (i && i.vmCount)
            ? a
            : i
            ? (Ee(i.value, n, a, void 0, i.shallow, i.mock), i.dep.notify(), a)
            : ((e[n] = a), a)
        }
      }
      function Pe(e, n) {
        if (t(e) && d(n)) e.splice(n, 1)
        else {
          var a = e.__ob__
          e._isVue || (a && a.vmCount) || $e(e) || (w(e, n) && (delete e[n], a && a.dep.notify()))
        }
      }
      function Be(e) {
        for (var n = void 0, a = 0, i = e.length; a < i; a++)
          (n = e[a]) && n.__ob__ && n.__ob__.dep.depend(), t(n) && Be(n)
      }
      function Ue(e) {
        return (
          (function (e, t) {
            $e(e) || Oe(e, t, ie())
          })(e, !0),
          q(e, '__v_isShallow', !0),
          e
        )
      }
      function $e(e) {
        return !(!e || !e.__v_isReadonly)
      }
      function De(e) {
        return !(!e || !0 !== e.__v_isRef)
      }
      function Ve(e, t, n) {
        Object.defineProperty(e, n, {
          enumerable: !0,
          configurable: !0,
          get: function () {
            var e = t[n]
            if (De(e)) return e.value
            var a = e && e.__ob__
            return a && a.dep.depend(), e
          },
          set: function (e) {
            var a = t[n]
            De(a) && !De(e) ? (a.value = e) : (t[n] = e)
          },
        })
      }
      var Ne = _(function (e) {
        var t = '&' === e.charAt(0),
          n = '~' === (e = t ? e.slice(1) : e).charAt(0),
          a = '!' === (e = n ? e.slice(1) : e).charAt(0)
        return { name: (e = a ? e.slice(1) : e), once: n, capture: a, passive: t }
      })
      function je(e, n) {
        function a() {
          var e = a.fns
          if (!t(e)) return Xt(e, null, arguments, n, 'v-on handler')
          for (var i = e.slice(), r = 0; r < i.length; r++) Xt(i[r], null, arguments, n, 'v-on handler')
        }
        return (a.fns = e), a
      }
      function Fe(e, t, n, i, s, o) {
        var u, p, l, d
        for (u in e)
          (p = e[u]),
            (l = t[u]),
            (d = Ne(u)),
            a(p) ||
              (a(l)
                ? (a(p.fns) && (p = e[u] = je(p, o)),
                  r(d.once) && (p = e[u] = s(d.name, p, d.capture)),
                  n(d.name, p, d.capture, d.passive, d.params))
                : p !== l && ((l.fns = p), (e[u] = l)))
        for (u in t) a(e[u]) && i((d = Ne(u)).name, t[u], d.capture)
      }
      function We(e, t, n) {
        var s
        e instanceof de && (e = e.data.hook || (e.data.hook = {}))
        var o = e[t]
        function u() {
          n.apply(this, arguments), b(s.fns, u)
        }
        a(o) ? (s = je([u])) : i(o.fns) && r(o.merged) ? (s = o).fns.push(u) : (s = je([o, u])),
          (s.merged = !0),
          (e[t] = s)
      }
      function Le(e, t, n, a, r) {
        if (i(t)) {
          if (w(t, n)) return (e[n] = t[n]), r || delete t[n], !0
          if (w(t, a)) return (e[n] = t[a]), r || delete t[a], !0
        }
        return !1
      }
      function qe(e) {
        return s(e) ? [ye(e)] : t(e) ? He(e) : void 0
      }
      function ze(e) {
        return i(e) && i(e.text) && !1 === e.isComment
      }
      function He(e, n) {
        var o,
          u,
          p,
          l,
          d = []
        for (o = 0; o < e.length; o++)
          a((u = e[o])) ||
            'boolean' == typeof u ||
            ((l = d[(p = d.length - 1)]),
            t(u)
              ? u.length > 0 &&
                (ze((u = He(u, ''.concat(n || '', '_').concat(o)))[0]) &&
                  ze(l) &&
                  ((d[p] = ye(l.text + u[0].text)), u.shift()),
                d.push.apply(d, u))
              : s(u)
              ? ze(l)
                ? (d[p] = ye(l.text + u))
                : '' !== u && d.push(ye(u))
              : ze(u) && ze(l)
              ? (d[p] = ye(l.text + u.text))
              : (r(e._isVList) && i(u.tag) && a(u.key) && i(n) && (u.key = '__vlist'.concat(n, '_').concat(o, '__')),
                d.push(u)))
        return d
      }
      var Ge = 1,
        Ke = 2
      function Je(e, n, a, p, l, d) {
        return (
          (t(a) || s(a)) && ((l = p), (p = a), (a = void 0)),
          r(d) && (l = Ke),
          (function (e, n, a, r, s) {
            if (i(a) && i(a.__ob__)) return ce()
            if ((i(a) && i(a.is) && (n = a.is), !n)) return ce()
            var p, l
            if (
              (t(r) && o(r[0]) && (((a = a || {}).scopedSlots = { default: r[0] }), (r.length = 0)),
              s === Ke
                ? (r = qe(r))
                : s === Ge &&
                  (r = (function (e) {
                    for (var n = 0; n < e.length; n++) if (t(e[n])) return Array.prototype.concat.apply([], e)
                    return e
                  })(r)),
              'string' == typeof n)
            ) {
              var d = void 0
              ;(l = (e.$vnode && e.$vnode.ns) || F.getTagNamespace(n)),
                (p = F.isReservedTag(n)
                  ? new de(F.parsePlatformTagName(n), a, r, void 0, void 0, e)
                  : (a && a.pre) || !i((d = Ln(e.$options, 'components', n)))
                  ? new de(n, a, r, void 0, void 0, e)
                  : Pn(d, a, e, r, n))
            } else p = Pn(n, a, e, r)
            return t(p)
              ? p
              : i(p)
              ? (i(l) && Xe(p, l),
                i(a) &&
                  (function (e) {
                    u(e.style) && cn(e.style), u(e.class) && cn(e.class)
                  })(a),
                p)
              : ce()
          })(e, n, a, p, l)
        )
      }
      function Xe(e, t, n) {
        if (((e.ns = t), 'foreignObject' === e.tag && ((t = void 0), (n = !0)), i(e.children)))
          for (var s = 0, o = e.children.length; s < o; s++) {
            var u = e.children[s]
            i(u.tag) && (a(u.ns) || (r(n) && 'svg' !== u.tag)) && Xe(u, t, n)
          }
      }
      function Ye(e, n) {
        var a,
          r,
          s,
          o,
          p = null
        if (t(e) || 'string' == typeof e)
          for (p = new Array(e.length), a = 0, r = e.length; a < r; a++) p[a] = n(e[a], a)
        else if ('number' == typeof e) for (p = new Array(e), a = 0; a < e; a++) p[a] = n(a + 1, a)
        else if (u(e))
          if (ue && e[Symbol.iterator]) {
            p = []
            for (var l = e[Symbol.iterator](), d = l.next(); !d.done; ) p.push(n(d.value, p.length)), (d = l.next())
          } else
            for (s = Object.keys(e), p = new Array(s.length), a = 0, r = s.length; a < r; a++)
              (o = s[a]), (p[a] = n(e[o], o, a))
        return i(p) || (p = []), (p._isVList = !0), p
      }
      function Ze(e, t, n, a) {
        var i,
          r = this.$scopedSlots[e]
        r
          ? ((n = n || {}), a && (n = O(O({}, a), n)), (i = r(n) || (o(t) ? t() : t)))
          : (i = this.$slots[e] || (o(t) ? t() : t))
        var s = n && n.slot
        return s ? this.$createElement('template', { slot: s }, i) : i
      }
      function Qe(e) {
        return Ln(this.$options, 'filters', e) || B
      }
      function et(e, n) {
        return t(e) ? -1 === e.indexOf(n) : e !== n
      }
      function tt(e, t, n, a, i) {
        var r = F.keyCodes[t] || n
        return i && a && !F.keyCodes[t] ? et(i, a) : r ? et(r, e) : a ? S(a) !== t : void 0 === e
      }
      function nt(e, n, a, i, r) {
        if (a && u(a)) {
          t(a) && (a = E(a))
          var s = void 0,
            o = function (t) {
              if ('class' === t || 'style' === t || T(t)) s = e
              else {
                var o = e.attrs && e.attrs.type
                s = i || F.mustUseProp(n, o, t) ? e.domProps || (e.domProps = {}) : e.attrs || (e.attrs = {})
              }
              var u = A(t),
                p = S(t)
              u in s ||
                p in s ||
                ((s[t] = a[t]),
                r &&
                  ((e.on || (e.on = {}))['update:'.concat(t)] = function (e) {
                    a[t] = e
                  }))
            }
          for (var p in a) o(p)
        }
        return e
      }
      function at(e, t) {
        var n = this._staticTrees || (this._staticTrees = []),
          a = n[e]
        return (
          (a && !t) ||
            rt(
              (a = n[e] = this.$options.staticRenderFns[e].call(this._renderProxy, this._c, this)),
              '__static__'.concat(e),
              !1
            ),
          a
        )
      }
      function it(e, t, n) {
        return rt(e, '__once__'.concat(t).concat(n ? '_'.concat(n) : ''), !0), e
      }
      function rt(e, n, a) {
        if (t(e))
          for (var i = 0; i < e.length; i++) e[i] && 'string' != typeof e[i] && st(e[i], ''.concat(n, '_').concat(i), a)
        else st(e, n, a)
      }
      function st(e, t, n) {
        ;(e.isStatic = !0), (e.key = t), (e.isOnce = n)
      }
      function ot(e, t) {
        if (t && l(t)) {
          var n = (e.on = e.on ? O({}, e.on) : {})
          for (var a in t) {
            var i = n[a],
              r = t[a]
            n[a] = i ? [].concat(i, r) : r
          }
        }
        return e
      }
      function ut(e, n, a, i) {
        n = n || { $stable: !a }
        for (var r = 0; r < e.length; r++) {
          var s = e[r]
          t(s) ? ut(s, n, a) : s && (s.proxy && (s.fn.proxy = !0), (n[s.key] = s.fn))
        }
        return i && (n.$key = i), n
      }
      function pt(e, t) {
        for (var n = 0; n < t.length; n += 2) {
          var a = t[n]
          'string' == typeof a && a && (e[t[n]] = t[n + 1])
        }
        return e
      }
      function lt(e, t) {
        return 'string' == typeof e ? t + e : e
      }
      function dt(e) {
        ;(e._o = it),
          (e._n = m),
          (e._s = y),
          (e._l = Ye),
          (e._t = Ze),
          (e._q = U),
          (e._i = $),
          (e._m = at),
          (e._f = Qe),
          (e._k = tt),
          (e._b = nt),
          (e._v = ye),
          (e._e = ce),
          (e._u = ut),
          (e._g = ot),
          (e._d = pt),
          (e._p = lt)
      }
      function ct(e, t) {
        if (!e || !e.length) return {}
        for (var n = {}, a = 0, i = e.length; a < i; a++) {
          var r = e[a],
            s = r.data
          if (
            (s && s.attrs && s.attrs.slot && delete s.attrs.slot,
            (r.context !== t && r.fnContext !== t) || !s || null == s.slot)
          )
            (n.default || (n.default = [])).push(r)
          else {
            var o = s.slot,
              u = n[o] || (n[o] = [])
            'template' === r.tag ? u.push.apply(u, r.children || []) : u.push(r)
          }
        }
        for (var p in n) n[p].every(yt) && delete n[p]
        return n
      }
      function yt(e) {
        return (e.isComment && !e.asyncFactory) || ' ' === e.text
      }
      function ft(e) {
        return e.isComment && e.asyncFactory
      }
      function mt(t, n, a, i) {
        var r,
          s = Object.keys(a).length > 0,
          o = n ? !!n.$stable : !s,
          u = n && n.$key
        if (n) {
          if (n._normalized) return n._normalized
          if (o && i && i !== e && u === i.$key && !s && !i.$hasNormal) return i
          for (var p in ((r = {}), n)) n[p] && '$' !== p[0] && (r[p] = ht(t, a, p, n[p]))
        } else r = {}
        for (var l in a) l in r || (r[l] = vt(a, l))
        return (
          n && Object.isExtensible(n) && (n._normalized = r),
          q(r, '$stable', o),
          q(r, '$key', u),
          q(r, '$hasNormal', s),
          r
        )
      }
      function ht(e, n, a, i) {
        var r = function () {
          var n = pe
          le(e)
          var a = arguments.length ? i.apply(null, arguments) : i({}),
            r = (a = a && 'object' == typeof a && !t(a) ? [a] : qe(a)) && a[0]
          return le(n), a && (!r || (1 === a.length && r.isComment && !ft(r))) ? void 0 : a
        }
        return i.proxy && Object.defineProperty(n, a, { get: r, enumerable: !0, configurable: !0 }), r
      }
      function vt(e, t) {
        return function () {
          return e[t]
        }
      }
      function Tt(e, t, n, a, i) {
        var r = !1
        for (var s in t) s in e ? t[s] !== n[s] && (r = !0) : ((r = !0), bt(e, s, a, i))
        for (var s in e) s in t || ((r = !0), delete e[s])
        return r
      }
      function bt(e, t, n, a) {
        Object.defineProperty(e, t, {
          enumerable: !0,
          configurable: !0,
          get: function () {
            return n[a][t]
          },
        })
      }
      function gt(e, t) {
        for (var n in t) e[n] = t[n]
        for (var n in e) n in t || delete e[n]
      }
      var wt,
        _t,
        kt = null
      function At(e, t) {
        return (e.__esModule || (ue && 'Module' === e[Symbol.toStringTag])) && (e = e.default), u(e) ? t.extend(e) : e
      }
      function Mt(e) {
        if (t(e))
          for (var n = 0; n < e.length; n++) {
            var a = e[n]
            if (i(a) && (i(a.componentOptions) || ft(a))) return a
          }
      }
      function Ct(e, t) {
        wt.$on(e, t)
      }
      function St(e, t) {
        wt.$off(e, t)
      }
      function xt(e, t) {
        var n = wt
        return function a() {
          null !== t.apply(null, arguments) && n.$off(e, a)
        }
      }
      function Rt(e, t, n) {
        ;(wt = e), Fe(t, n || {}, Ct, St, xt, e), (wt = void 0)
      }
      var Ot = (function () {
          function e(e) {
            void 0 === e && (e = !1),
              (this.detached = e),
              (this.active = !0),
              (this.effects = []),
              (this.cleanups = []),
              (this.parent = _t),
              !e && _t && (this.index = (_t.scopes || (_t.scopes = [])).push(this) - 1)
          }
          return (
            (e.prototype.run = function (e) {
              if (this.active) {
                var t = _t
                try {
                  return (_t = this), e()
                } finally {
                  _t = t
                }
              }
            }),
            (e.prototype.on = function () {
              _t = this
            }),
            (e.prototype.off = function () {
              _t = this.parent
            }),
            (e.prototype.stop = function (e) {
              if (this.active) {
                var t = void 0,
                  n = void 0
                for (t = 0, n = this.effects.length; t < n; t++) this.effects[t].teardown()
                for (t = 0, n = this.cleanups.length; t < n; t++) this.cleanups[t]()
                if (this.scopes) for (t = 0, n = this.scopes.length; t < n; t++) this.scopes[t].stop(!0)
                if (!this.detached && this.parent && !e) {
                  var a = this.parent.scopes.pop()
                  a && a !== this && ((this.parent.scopes[this.index] = a), (a.index = this.index))
                }
                ;(this.parent = void 0), (this.active = !1)
              }
            }),
            e
          )
        })(),
        Et = null
      function It(e) {
        var t = Et
        return (
          (Et = e),
          function () {
            Et = t
          }
        )
      }
      function Pt(e) {
        for (; e && (e = e.$parent); ) if (e._inactive) return !0
        return !1
      }
      function Bt(e, t) {
        if (t) {
          if (((e._directInactive = !1), Pt(e))) return
        } else if (e._directInactive) return
        if (e._inactive || null === e._inactive) {
          e._inactive = !1
          for (var n = 0; n < e.$children.length; n++) Bt(e.$children[n])
          $t(e, 'activated')
        }
      }
      function Ut(e, t) {
        if (!((t && ((e._directInactive = !0), Pt(e))) || e._inactive)) {
          e._inactive = !0
          for (var n = 0; n < e.$children.length; n++) Ut(e.$children[n])
          $t(e, 'deactivated')
        }
      }
      function $t(e, t, n, a) {
        void 0 === a && (a = !0), ge()
        var i = pe,
          r = _t
        a && le(e)
        var s = e.$options[t],
          o = ''.concat(t, ' hook')
        if (s) for (var u = 0, p = s.length; u < p; u++) Xt(s[u], e, n || null, e, o)
        e._hasHookEvent && e.$emit('hook:' + t), a && (le(i), r && r.on()), we()
      }
      var Dt = [],
        Vt = [],
        Nt = {},
        jt = !1,
        Ft = !1,
        Wt = 0,
        Lt = 0,
        qt = Date.now
      if (G && !J) {
        var zt = window.performance
        zt &&
          'function' == typeof zt.now &&
          qt() > document.createEvent('Event').timeStamp &&
          (qt = function () {
            return zt.now()
          })
      }
      var Ht = function (e, t) {
        if (e.post) {
          if (!t.post) return 1
        } else if (t.post) return -1
        return e.id - t.id
      }
      function Gt() {
        var e, t
        for (Lt = qt(), Ft = !0, Dt.sort(Ht), Wt = 0; Wt < Dt.length; Wt++)
          (e = Dt[Wt]).before && e.before(), (t = e.id), (Nt[t] = null), e.run()
        var n = Vt.slice(),
          a = Dt.slice()
        ;(Wt = Dt.length = Vt.length = 0),
          (Nt = {}),
          (jt = Ft = !1),
          (function (e) {
            for (var t = 0; t < e.length; t++) (e[t]._inactive = !0), Bt(e[t], !0)
          })(n),
          (function (e) {
            for (var t = e.length; t--; ) {
              var n = e[t],
                a = n.vm
              a && a._watcher === n && a._isMounted && !a._isDestroyed && $t(a, 'updated')
            }
          })(a),
          ve(),
          re && F.devtools && re.emit('flush')
      }
      var Kt = 'watcher'
      function Jt(e, t, n) {
        ge()
        try {
          if (t)
            for (var a = t; (a = a.$parent); ) {
              var i = a.$options.errorCaptured
              if (i)
                for (var r = 0; r < i.length; r++)
                  try {
                    if (!1 === i[r].call(a, e, t, n)) return
                  } catch (e) {
                    Yt(e, a, 'errorCaptured hook')
                  }
            }
          Yt(e, t, n)
        } finally {
          we()
        }
      }
      function Xt(e, t, n, a, i) {
        var r
        try {
          ;(r = n ? e.apply(t, n) : e.call(t)) &&
            !r._isVue &&
            c(r) &&
            !r._handled &&
            (r.catch(function (e) {
              return Jt(e, a, i + ' (Promise/async)')
            }),
            (r._handled = !0))
        } catch (e) {
          Jt(e, a, i)
        }
        return r
      }
      function Yt(e, t, n) {
        if (F.errorHandler)
          try {
            return F.errorHandler.call(null, e, t, n)
          } catch (t) {
            t !== e && Zt(t)
          }
        Zt(e)
      }
      function Zt(e, t, n) {
        if (!G || 'undefined' == typeof console) throw e
        console.error(e)
      }
      ''.concat(Kt, ' callback'), ''.concat(Kt, ' getter'), ''.concat(Kt, ' cleanup')
      var Qt,
        en = !1,
        tn = [],
        nn = !1
      function an() {
        nn = !1
        var e = tn.slice(0)
        tn.length = 0
        for (var t = 0; t < e.length; t++) e[t]()
      }
      if ('undefined' != typeof Promise && se(Promise)) {
        var rn = Promise.resolve()
        ;(Qt = function () {
          rn.then(an), Z && setTimeout(I)
        }),
          (en = !0)
      } else if (
        J ||
        'undefined' == typeof MutationObserver ||
        (!se(MutationObserver) && '[object MutationObserverConstructor]' !== MutationObserver.toString())
      )
        Qt =
          'undefined' != typeof setImmediate && se(setImmediate)
            ? function () {
                setImmediate(an)
              }
            : function () {
                setTimeout(an, 0)
              }
      else {
        var sn = 1,
          on = new MutationObserver(an),
          un = document.createTextNode(String(sn))
        on.observe(un, { characterData: !0 }),
          (Qt = function () {
            ;(sn = (sn + 1) % 2), (un.data = String(sn))
          }),
          (en = !0)
      }
      function pn(e, t) {
        var n
        if (
          (tn.push(function () {
            if (e)
              try {
                e.call(t)
              } catch (e) {
                Jt(e, t, 'nextTick')
              }
            else n && n(t)
          }),
          nn || ((nn = !0), Qt()),
          !e && 'undefined' != typeof Promise)
        )
          return new Promise(function (e) {
            n = e
          })
      }
      function ln(e) {
        return function (t, n) {
          if ((void 0 === n && (n = pe), n))
            return (function (e, t, n) {
              var a = e.$options
              a[t] = Nn(a[t], n)
            })(n, e, t)
        }
      }
      ln('beforeMount'),
        ln('mounted'),
        ln('beforeUpdate'),
        ln('updated'),
        ln('beforeDestroy'),
        ln('destroyed'),
        ln('activated'),
        ln('deactivated'),
        ln('serverPrefetch'),
        ln('renderTracked'),
        ln('renderTriggered'),
        ln('errorCaptured')
      var dn = new oe()
      function cn(e) {
        return yn(e, dn), dn.clear(), e
      }
      function yn(e, n) {
        var a,
          i,
          r = t(e)
        if (!((!r && !u(e)) || e.__v_skip || Object.isFrozen(e) || e instanceof de)) {
          if (e.__ob__) {
            var s = e.__ob__.dep.id
            if (n.has(s)) return
            n.add(s)
          }
          if (r) for (a = e.length; a--; ) yn(e[a], n)
          else if (De(e)) yn(e.value, n)
          else for (a = (i = Object.keys(e)).length; a--; ) yn(e[i[a]], n)
        }
      }
      var fn = 0,
        mn = (function () {
          function e(e, t, n, a, i) {
            var r
            void 0 === (r = _t && !_t._vm ? _t : e ? e._scope : void 0) && (r = _t),
              r && r.active && r.effects.push(this),
              (this.vm = e) && i && (e._watcher = this),
              a
                ? ((this.deep = !!a.deep),
                  (this.user = !!a.user),
                  (this.lazy = !!a.lazy),
                  (this.sync = !!a.sync),
                  (this.before = a.before))
                : (this.deep = this.user = this.lazy = this.sync = !1),
              (this.cb = n),
              (this.id = ++fn),
              (this.active = !0),
              (this.post = !1),
              (this.dirty = this.lazy),
              (this.deps = []),
              (this.newDeps = []),
              (this.depIds = new oe()),
              (this.newDepIds = new oe()),
              (this.expression = ''),
              o(t)
                ? (this.getter = t)
                : ((this.getter = (function (e) {
                    if (!z.test(e)) {
                      var t = e.split('.')
                      return function (e) {
                        for (var n = 0; n < t.length; n++) {
                          if (!e) return
                          e = e[t[n]]
                        }
                        return e
                      }
                    }
                  })(t)),
                  this.getter || (this.getter = I)),
              (this.value = this.lazy ? void 0 : this.get())
          }
          return (
            (e.prototype.get = function () {
              var e
              ge(this)
              var t = this.vm
              try {
                e = this.getter.call(t, t)
              } catch (e) {
                if (!this.user) throw e
                Jt(e, t, 'getter for watcher "'.concat(this.expression, '"'))
              } finally {
                this.deep && cn(e), we(), this.cleanupDeps()
              }
              return e
            }),
            (e.prototype.addDep = function (e) {
              var t = e.id
              this.newDepIds.has(t) ||
                (this.newDepIds.add(t), this.newDeps.push(e), this.depIds.has(t) || e.addSub(this))
            }),
            (e.prototype.cleanupDeps = function () {
              for (var e = this.deps.length; e--; ) {
                var t = this.deps[e]
                this.newDepIds.has(t.id) || t.removeSub(this)
              }
              var n = this.depIds
              ;(this.depIds = this.newDepIds),
                (this.newDepIds = n),
                this.newDepIds.clear(),
                (n = this.deps),
                (this.deps = this.newDeps),
                (this.newDeps = n),
                (this.newDeps.length = 0)
            }),
            (e.prototype.update = function () {
              this.lazy
                ? (this.dirty = !0)
                : this.sync
                ? this.run()
                : (function (e) {
                    var t = e.id
                    if (null == Nt[t] && (e !== Te.target || !e.noRecurse)) {
                      if (((Nt[t] = !0), Ft)) {
                        for (var n = Dt.length - 1; n > Wt && Dt[n].id > e.id; ) n--
                        Dt.splice(n + 1, 0, e)
                      } else Dt.push(e)
                      jt || ((jt = !0), pn(Gt))
                    }
                  })(this)
            }),
            (e.prototype.run = function () {
              if (this.active) {
                var e = this.get()
                if (e !== this.value || u(e) || this.deep) {
                  var t = this.value
                  if (((this.value = e), this.user)) {
                    var n = 'callback for watcher "'.concat(this.expression, '"')
                    Xt(this.cb, this.vm, [e, t], this.vm, n)
                  } else this.cb.call(this.vm, e, t)
                }
              }
            }),
            (e.prototype.evaluate = function () {
              ;(this.value = this.get()), (this.dirty = !1)
            }),
            (e.prototype.depend = function () {
              for (var e = this.deps.length; e--; ) this.deps[e].depend()
            }),
            (e.prototype.teardown = function () {
              if ((this.vm && !this.vm._isBeingDestroyed && b(this.vm._scope.effects, this), this.active)) {
                for (var e = this.deps.length; e--; ) this.deps[e].removeSub(this)
                ;(this.active = !1), this.onStop && this.onStop()
              }
            }),
            e
          )
        })(),
        hn = { enumerable: !0, configurable: !0, get: I, set: I }
      function vn(e, t, n) {
        ;(hn.get = function () {
          return this[t][n]
        }),
          (hn.set = function (e) {
            this[t][n] = e
          }),
          Object.defineProperty(e, n, hn)
      }
      function Tn(n) {
        var a = n.$options
        if (
          (a.props &&
            (function (e, t) {
              var n = e.$options.propsData || {},
                a = (e._props = Ue({})),
                i = (e.$options._propKeys = [])
              !e.$parent || Se(!1)
              var r = function (r) {
                i.push(r)
                var s = qn(r, t, n, e)
                Ee(a, r, s, void 0, !0), r in e || vn(e, '_props', r)
              }
              for (var s in t) r(s)
              Se(!0)
            })(n, a.props),
          (function (t) {
            var n = t.$options,
              a = n.setup
            if (a) {
              var i = (t._setupContext = (function (t) {
                return {
                  get attrs() {
                    if (!t._attrsProxy) {
                      var n = (t._attrsProxy = {})
                      q(n, '_v_attr_proxy', !0), Tt(n, t.$attrs, e, t, '$attrs')
                    }
                    return t._attrsProxy
                  },
                  get listeners() {
                    return (
                      t._listenersProxy || Tt((t._listenersProxy = {}), t.$listeners, e, t, '$listeners'),
                      t._listenersProxy
                    )
                  },
                  get slots() {
                    return (function (e) {
                      return e._slotsProxy || gt((e._slotsProxy = {}), e.$scopedSlots), e._slotsProxy
                    })(t)
                  },
                  emit: x(t.$emit, t),
                  expose: function (e) {
                    e &&
                      Object.keys(e).forEach(function (n) {
                        return Ve(t, e, n)
                      })
                  },
                }
              })(t))
              le(t), ge()
              var r = Xt(a, null, [t._props || Ue({}), i], t, 'setup')
              if ((we(), le(), o(r))) n.render = r
              else if (u(r))
                if (((t._setupState = r), r.__sfc)) {
                  var s = (t._setupProxy = {})
                  for (var p in r) '__sfc' !== p && Ve(s, r, p)
                } else for (var p in r) L(p) || Ve(t, r, p)
            }
          })(n),
          a.methods &&
            (function (e, t) {
              for (var n in (e.$options.props, t)) e[n] = 'function' != typeof t[n] ? I : x(t[n], e)
            })(n, a.methods),
          a.data)
        )
          !(function (e) {
            var t = e.$options.data
            l(
              (t = e._data =
                o(t)
                  ? (function (e, t) {
                      ge()
                      try {
                        return e.call(t, t)
                      } catch (e) {
                        return Jt(e, t, 'data()'), {}
                      } finally {
                        we()
                      }
                    })(t, e)
                  : t || {})
            ) || (t = {})
            for (var n = Object.keys(t), a = e.$options.props, i = (e.$options.methods, n.length); i--; ) {
              var r = n[i]
              ;(a && w(a, r)) || L(r) || vn(e, '_data', r)
            }
            var s = Oe(t)
            s && s.vmCount++
          })(n)
        else {
          var i = Oe((n._data = {}))
          i && i.vmCount++
        }
        a.computed &&
          (function (e, t) {
            var n = (e._computedWatchers = Object.create(null)),
              a = ie()
            for (var i in t) {
              var r = t[i],
                s = o(r) ? r : r.get
              a || (n[i] = new mn(e, s || I, I, bn)), i in e || gn(e, i, r)
            }
          })(n, a.computed),
          a.watch &&
            a.watch !== te &&
            (function (e, n) {
              for (var a in n) {
                var i = n[a]
                if (t(i)) for (var r = 0; r < i.length; r++) kn(e, a, i[r])
                else kn(e, a, i)
              }
            })(n, a.watch)
      }
      var bn = { lazy: !0 }
      function gn(e, t, n) {
        var a = !ie()
        o(n)
          ? ((hn.get = a ? wn(t) : _n(n)), (hn.set = I))
          : ((hn.get = n.get ? (a && !1 !== n.cache ? wn(t) : _n(n.get)) : I), (hn.set = n.set || I)),
          Object.defineProperty(e, t, hn)
      }
      function wn(e) {
        return function () {
          var t = this._computedWatchers && this._computedWatchers[e]
          if (t) return t.dirty && t.evaluate(), Te.target && t.depend(), t.value
        }
      }
      function _n(e) {
        return function () {
          return e.call(this, this)
        }
      }
      function kn(e, t, n, a) {
        return l(n) && ((a = n), (n = n.handler)), 'string' == typeof n && (n = e[n]), e.$watch(t, n, a)
      }
      function An(e, t) {
        if (e) {
          for (var n = Object.create(null), a = ue ? Reflect.ownKeys(e) : Object.keys(e), i = 0; i < a.length; i++) {
            var r = a[i]
            if ('__ob__' !== r) {
              var s = e[r].from
              if (s in t._provided) n[r] = t._provided[s]
              else if ('default' in e[r]) {
                var u = e[r].default
                n[r] = o(u) ? u.call(t) : u
              }
            }
          }
          return n
        }
      }
      var Mn = 0
      function Cn(e) {
        var t = e.options
        if (e.super) {
          var n = Cn(e.super)
          if (n !== e.superOptions) {
            e.superOptions = n
            var a = (function (e) {
              var t,
                n = e.options,
                a = e.sealedOptions
              for (var i in n) n[i] !== a[i] && (t || (t = {}), (t[i] = n[i]))
              return t
            })(e)
            a && O(e.extendOptions, a), (t = e.options = Wn(n, e.extendOptions)).name && (t.components[t.name] = e)
          }
        }
        return t
      }
      function Sn(n, a, i, s, o) {
        var u,
          p = this,
          l = o.options
        w(s, '_uid') ? ((u = Object.create(s))._original = s) : ((u = s), (s = s._original))
        var d = r(l._compiled),
          c = !d
        ;(this.data = n),
          (this.props = a),
          (this.children = i),
          (this.parent = s),
          (this.listeners = n.on || e),
          (this.injections = An(l.inject, s)),
          (this.slots = function () {
            return p.$slots || mt(s, n.scopedSlots, (p.$slots = ct(i, s))), p.$slots
          }),
          Object.defineProperty(this, 'scopedSlots', {
            enumerable: !0,
            get: function () {
              return mt(s, n.scopedSlots, this.slots())
            },
          }),
          d &&
            ((this.$options = l),
            (this.$slots = this.slots()),
            (this.$scopedSlots = mt(s, n.scopedSlots, this.$slots))),
          l._scopeId
            ? (this._c = function (e, n, a, i) {
                var r = Je(u, e, n, a, i, c)
                return r && !t(r) && ((r.fnScopeId = l._scopeId), (r.fnContext = s)), r
              })
            : (this._c = function (e, t, n, a) {
                return Je(u, e, t, n, a, c)
              })
      }
      function xn(e, t, n, a, i) {
        var r = fe(e)
        return (r.fnContext = n), (r.fnOptions = a), t.slot && ((r.data || (r.data = {})).slot = t.slot), r
      }
      function Rn(e, t) {
        for (var n in t) e[A(n)] = t[n]
      }
      function On(e) {
        return e.name || e.__name || e._componentTag
      }
      dt(Sn.prototype)
      var En = {
          init: function (e, t) {
            if (e.componentInstance && !e.componentInstance._isDestroyed && e.data.keepAlive) {
              var n = e
              En.prepatch(n, n)
            } else
              (e.componentInstance = (function (e, t) {
                var n = { _isComponent: !0, _parentVnode: e, parent: t },
                  a = e.data.inlineTemplate
                return (
                  i(a) && ((n.render = a.render), (n.staticRenderFns = a.staticRenderFns)),
                  new e.componentOptions.Ctor(n)
                )
              })(e, Et)).$mount(t ? e.elm : void 0, t)
          },
          prepatch: function (t, n) {
            var a = n.componentOptions
            !(function (t, n, a, i, r) {
              var s = i.data.scopedSlots,
                o = t.$scopedSlots,
                u = !!(
                  (s && !s.$stable) ||
                  (o !== e && !o.$stable) ||
                  (s && t.$scopedSlots.$key !== s.$key) ||
                  (!s && t.$scopedSlots.$key)
                ),
                p = !!(r || t.$options._renderChildren || u),
                l = t.$vnode
              ;(t.$options._parentVnode = i),
                (t.$vnode = i),
                t._vnode && (t._vnode.parent = i),
                (t.$options._renderChildren = r)
              var d = i.data.attrs || e
              t._attrsProxy && Tt(t._attrsProxy, d, (l.data && l.data.attrs) || e, t, '$attrs') && (p = !0),
                (t.$attrs = d),
                (a = a || e)
              var c = t.$options._parentListeners
              if (
                (t._listenersProxy && Tt(t._listenersProxy, a, c || e, t, '$listeners'),
                (t.$listeners = t.$options._parentListeners = a),
                Rt(t, a, c),
                n && t.$options.props)
              ) {
                Se(!1)
                for (var y = t._props, f = t.$options._propKeys || [], m = 0; m < f.length; m++) {
                  var h = f[m],
                    v = t.$options.props
                  y[h] = qn(h, v, n, t)
                }
                Se(!0), (t.$options.propsData = n)
              }
              p && ((t.$slots = ct(r, i.context)), t.$forceUpdate())
            })((n.componentInstance = t.componentInstance), a.propsData, a.listeners, n, a.children)
          },
          insert: function (e) {
            var t,
              n = e.context,
              a = e.componentInstance
            a._isMounted || ((a._isMounted = !0), $t(a, 'mounted')),
              e.data.keepAlive && (n._isMounted ? (((t = a)._inactive = !1), Vt.push(t)) : Bt(a, !0))
          },
          destroy: function (e) {
            var t = e.componentInstance
            t._isDestroyed || (e.data.keepAlive ? Ut(t, !0) : t.$destroy())
          },
        },
        In = Object.keys(En)
      function Pn(n, s, o, p, l) {
        if (!a(n)) {
          var d = o.$options._base
          if ((u(n) && (n = d.extend(n)), 'function' == typeof n)) {
            var y
            if (
              a(n.cid) &&
              ((n = (function (e, t) {
                if (r(e.error) && i(e.errorComp)) return e.errorComp
                if (i(e.resolved)) return e.resolved
                var n = kt
                if (
                  (n && i(e.owners) && -1 === e.owners.indexOf(n) && e.owners.push(n), r(e.loading) && i(e.loadingComp))
                )
                  return e.loadingComp
                if (n && !i(e.owners)) {
                  var s = (e.owners = [n]),
                    o = !0,
                    p = null,
                    l = null
                  n.$on('hook:destroyed', function () {
                    return b(s, n)
                  })
                  var d = function (e) {
                      for (var t = 0, n = s.length; t < n; t++) s[t].$forceUpdate()
                      e &&
                        ((s.length = 0),
                        null !== p && (clearTimeout(p), (p = null)),
                        null !== l && (clearTimeout(l), (l = null)))
                    },
                    y = D(function (n) {
                      ;(e.resolved = At(n, t)), o ? (s.length = 0) : d(!0)
                    }),
                    f = D(function (t) {
                      i(e.errorComp) && ((e.error = !0), d(!0))
                    }),
                    m = e(y, f)
                  return (
                    u(m) &&
                      (c(m)
                        ? a(e.resolved) && m.then(y, f)
                        : c(m.component) &&
                          (m.component.then(y, f),
                          i(m.error) && (e.errorComp = At(m.error, t)),
                          i(m.loading) &&
                            ((e.loadingComp = At(m.loading, t)),
                            0 === m.delay
                              ? (e.loading = !0)
                              : (p = setTimeout(function () {
                                  ;(p = null), a(e.resolved) && a(e.error) && ((e.loading = !0), d(!1))
                                }, m.delay || 200))),
                          i(m.timeout) &&
                            (l = setTimeout(function () {
                              ;(l = null), a(e.resolved) && f(null)
                            }, m.timeout)))),
                    (o = !1),
                    e.loading ? e.loadingComp : e.resolved
                  )
                }
              })((y = n), d)),
              void 0 === n)
            )
              return (function (e, t, n, a, i) {
                var r = ce()
                return (r.asyncFactory = e), (r.asyncMeta = { data: t, context: n, children: a, tag: i }), r
              })(y, s, o, p, l)
            ;(s = s || {}),
              Cn(n),
              i(s.model) &&
                (function (e, n) {
                  var a = (e.model && e.model.prop) || 'value',
                    r = (e.model && e.model.event) || 'input'
                  ;(n.attrs || (n.attrs = {}))[a] = n.model.value
                  var s = n.on || (n.on = {}),
                    o = s[r],
                    u = n.model.callback
                  i(o) ? (t(o) ? -1 === o.indexOf(u) : o !== u) && (s[r] = [u].concat(o)) : (s[r] = u)
                })(n.options, s)
            var f = (function (e, t, n) {
              var r = t.options.props
              if (!a(r)) {
                var s = {},
                  o = e.attrs,
                  u = e.props
                if (i(o) || i(u))
                  for (var p in r) {
                    var l = S(p)
                    Le(s, u, p, l, !0) || Le(s, o, p, l, !1)
                  }
                return s
              }
            })(s, n)
            if (r(n.options.functional))
              return (function (n, a, r, s, o) {
                var u = n.options,
                  p = {},
                  l = u.props
                if (i(l)) for (var d in l) p[d] = qn(d, l, a || e)
                else i(r.attrs) && Rn(p, r.attrs), i(r.props) && Rn(p, r.props)
                var c = new Sn(r, p, o, s, n),
                  y = u.render.call(null, c._c, c)
                if (y instanceof de) return xn(y, r, c.parent, u)
                if (t(y)) {
                  for (var f = qe(y) || [], m = new Array(f.length), h = 0; h < f.length; h++)
                    m[h] = xn(f[h], r, c.parent, u)
                  return m
                }
              })(n, f, s, o, p)
            var m = s.on
            if (((s.on = s.nativeOn), r(n.options.abstract))) {
              var h = s.slot
              ;(s = {}), h && (s.slot = h)
            }
            !(function (e) {
              for (var t = e.hook || (e.hook = {}), n = 0; n < In.length; n++) {
                var a = In[n],
                  i = t[a],
                  r = En[a]
                i === r || (i && i._merged) || (t[a] = i ? Bn(r, i) : r)
              }
            })(s)
            var v = On(n.options) || l
            return new de(
              'vue-component-'.concat(n.cid).concat(v ? '-'.concat(v) : ''),
              s,
              void 0,
              void 0,
              void 0,
              o,
              { Ctor: n, propsData: f, listeners: m, tag: l, children: p },
              y
            )
          }
        }
      }
      function Bn(e, t) {
        var n = function (n, a) {
          e(n, a), t(n, a)
        }
        return (n._merged = !0), n
      }
      var Un = I,
        $n = F.optionMergeStrategies
      function Dn(e, t, n) {
        if ((void 0 === n && (n = !0), !t)) return e
        for (var a, i, r, s = ue ? Reflect.ownKeys(t) : Object.keys(t), o = 0; o < s.length; o++)
          '__ob__' !== (a = s[o]) &&
            ((i = e[a]), (r = t[a]), n && w(e, a) ? i !== r && l(i) && l(r) && Dn(i, r) : Ie(e, a, r))
        return e
      }
      function Vn(e, t, n) {
        return n
          ? function () {
              var a = o(t) ? t.call(n, n) : t,
                i = o(e) ? e.call(n, n) : e
              return a ? Dn(a, i) : i
            }
          : t
          ? e
            ? function () {
                return Dn(o(t) ? t.call(this, this) : t, o(e) ? e.call(this, this) : e)
              }
            : t
          : e
      }
      function Nn(e, n) {
        var a = n ? (e ? e.concat(n) : t(n) ? n : [n]) : e
        return a
          ? (function (e) {
              for (var t = [], n = 0; n < e.length; n++) -1 === t.indexOf(e[n]) && t.push(e[n])
              return t
            })(a)
          : a
      }
      function jn(e, t, n, a) {
        var i = Object.create(e || null)
        return t ? O(i, t) : i
      }
      ;($n.data = function (e, t, n) {
        return n ? Vn(e, t, n) : t && 'function' != typeof t ? e : Vn(e, t)
      }),
        j.forEach(function (e) {
          $n[e] = Nn
        }),
        N.forEach(function (e) {
          $n[e + 's'] = jn
        }),
        ($n.watch = function (e, n, a, i) {
          if ((e === te && (e = void 0), n === te && (n = void 0), !n)) return Object.create(e || null)
          if (!e) return n
          var r = {}
          for (var s in (O(r, e), n)) {
            var o = r[s],
              u = n[s]
            o && !t(o) && (o = [o]), (r[s] = o ? o.concat(u) : t(u) ? u : [u])
          }
          return r
        }),
        ($n.props =
          $n.methods =
          $n.inject =
          $n.computed =
            function (e, t, n, a) {
              if (!e) return t
              var i = Object.create(null)
              return O(i, e), t && O(i, t), i
            }),
        ($n.provide = function (e, t) {
          return e
            ? function () {
                var n = Object.create(null)
                return Dn(n, o(e) ? e.call(this) : e), t && Dn(n, o(t) ? t.call(this) : t, !1), n
              }
            : t
        })
      var Fn = function (e, t) {
        return void 0 === t ? e : t
      }
      function Wn(e, n, a) {
        if (
          (o(n) && (n = n.options),
          (function (e, n) {
            var a = e.props
            if (a) {
              var i,
                r,
                s = {}
              if (t(a)) for (i = a.length; i--; ) 'string' == typeof (r = a[i]) && (s[A(r)] = { type: null })
              else if (l(a)) for (var o in a) (r = a[o]), (s[A(o)] = l(r) ? r : { type: r })
              e.props = s
            }
          })(n),
          (function (e, n) {
            var a = e.inject
            if (a) {
              var i = (e.inject = {})
              if (t(a)) for (var r = 0; r < a.length; r++) i[a[r]] = { from: a[r] }
              else if (l(a))
                for (var s in a) {
                  var o = a[s]
                  i[s] = l(o) ? O({ from: s }, o) : { from: o }
                }
            }
          })(n),
          (function (e) {
            var t = e.directives
            if (t)
              for (var n in t) {
                var a = t[n]
                o(a) && (t[n] = { bind: a, update: a })
              }
          })(n),
          !n._base && (n.extends && (e = Wn(e, n.extends, a)), n.mixins))
        )
          for (var i = 0, r = n.mixins.length; i < r; i++) e = Wn(e, n.mixins[i], a)
        var s,
          u = {}
        for (s in e) p(s)
        for (s in n) w(e, s) || p(s)
        function p(t) {
          var i = $n[t] || Fn
          u[t] = i(e[t], n[t], a, t)
        }
        return u
      }
      function Ln(e, t, n, a) {
        if ('string' == typeof n) {
          var i = e[t]
          if (w(i, n)) return i[n]
          var r = A(n)
          if (w(i, r)) return i[r]
          var s = M(r)
          return w(i, s) ? i[s] : i[n] || i[r] || i[s]
        }
      }
      function qn(e, t, n, a) {
        var i = t[e],
          r = !w(n, e),
          s = n[e],
          u = Kn(Boolean, i.type)
        if (u > -1)
          if (r && !w(i, 'default')) s = !1
          else if ('' === s || s === S(e)) {
            var p = Kn(String, i.type)
            ;(p < 0 || u < p) && (s = !0)
          }
        if (void 0 === s) {
          s = (function (e, t, n) {
            if (w(t, 'default')) {
              var a = t.default
              return e && e.$options.propsData && void 0 === e.$options.propsData[n] && void 0 !== e._props[n]
                ? e._props[n]
                : o(a) && 'Function' !== Hn(t.type)
                ? a.call(e)
                : a
            }
          })(a, i, e)
          var l = Ce
          Se(!0), Oe(s), Se(l)
        }
        return s
      }
      var zn = /^\s*function (\w+)/
      function Hn(e) {
        var t = e && e.toString().match(zn)
        return t ? t[1] : ''
      }
      function Gn(e, t) {
        return Hn(e) === Hn(t)
      }
      function Kn(e, n) {
        if (!t(n)) return Gn(n, e) ? 0 : -1
        for (var a = 0, i = n.length; a < i; a++) if (Gn(n[a], e)) return a
        return -1
      }
      function Jn(e) {
        this._init(e)
      }
      function Xn(e) {
        return e && (On(e.Ctor.options) || e.tag)
      }
      function Yn(e, n) {
        return t(e)
          ? e.indexOf(n) > -1
          : 'string' == typeof e
          ? e.split(',').indexOf(n) > -1
          : ((a = e), !('[object RegExp]' !== p.call(a)) && e.test(n))
        var a
      }
      function Zn(e, t) {
        var n = e.cache,
          a = e.keys,
          i = e._vnode,
          r = e.$vnode
        for (var s in n) {
          var o = n[s]
          if (o) {
            var u = o.name
            u && !t(u) && Qn(n, s, a, i)
          }
        }
        r.componentOptions.children = void 0
      }
      function Qn(e, t, n, a) {
        var i = e[t]
        !i || (a && i.tag === a.tag) || i.componentInstance.$destroy(), (e[t] = null), b(n, t)
      }
      !(function (t) {
        t.prototype._init = function (t) {
          var n = this
          ;(n._uid = Mn++),
            (n._isVue = !0),
            (n.__v_skip = !0),
            (n._scope = new Ot(!0)),
            (n._scope.parent = void 0),
            (n._scope._vm = !0),
            t && t._isComponent
              ? (function (e, t) {
                  var n = (e.$options = Object.create(e.constructor.options)),
                    a = t._parentVnode
                  ;(n.parent = t.parent), (n._parentVnode = a)
                  var i = a.componentOptions
                  ;(n.propsData = i.propsData),
                    (n._parentListeners = i.listeners),
                    (n._renderChildren = i.children),
                    (n._componentTag = i.tag),
                    t.render && ((n.render = t.render), (n.staticRenderFns = t.staticRenderFns))
                })(n, t)
              : (n.$options = Wn(Cn(n.constructor), t || {}, n)),
            (n._renderProxy = n),
            (n._self = n),
            (function (e) {
              var t = e.$options,
                n = t.parent
              if (n && !t.abstract) {
                for (; n.$options.abstract && n.$parent; ) n = n.$parent
                n.$children.push(e)
              }
              ;(e.$parent = n),
                (e.$root = n ? n.$root : e),
                (e.$children = []),
                (e.$refs = {}),
                (e._provided = n ? n._provided : Object.create(null)),
                (e._watcher = null),
                (e._inactive = null),
                (e._directInactive = !1),
                (e._isMounted = !1),
                (e._isDestroyed = !1),
                (e._isBeingDestroyed = !1)
            })(n),
            (function (e) {
              ;(e._events = Object.create(null)), (e._hasHookEvent = !1)
              var t = e.$options._parentListeners
              t && Rt(e, t)
            })(n),
            (function (t) {
              ;(t._vnode = null), (t._staticTrees = null)
              var n = t.$options,
                a = (t.$vnode = n._parentVnode),
                i = a && a.context
              ;(t.$slots = ct(n._renderChildren, i)),
                (t.$scopedSlots = a ? mt(t.$parent, a.data.scopedSlots, t.$slots) : e),
                (t._c = function (e, n, a, i) {
                  return Je(t, e, n, a, i, !1)
                }),
                (t.$createElement = function (e, n, a, i) {
                  return Je(t, e, n, a, i, !0)
                })
              var r = a && a.data
              Ee(t, '$attrs', (r && r.attrs) || e, null, !0), Ee(t, '$listeners', n._parentListeners || e, null, !0)
            })(n),
            $t(n, 'beforeCreate', void 0, !1),
            (function (e) {
              var t = An(e.$options.inject, e)
              t &&
                (Se(!1),
                Object.keys(t).forEach(function (n) {
                  Ee(e, n, t[n])
                }),
                Se(!0))
            })(n),
            Tn(n),
            (function (e) {
              var t = e.$options.provide
              if (t) {
                var n = o(t) ? t.call(e) : t
                if (!u(n)) return
                for (
                  var a = (function (e) {
                      var t = e._provided,
                        n = e.$parent && e.$parent._provided
                      return n === t ? (e._provided = Object.create(n)) : t
                    })(e),
                    i = ue ? Reflect.ownKeys(n) : Object.keys(n),
                    r = 0;
                  r < i.length;
                  r++
                ) {
                  var s = i[r]
                  Object.defineProperty(a, s, Object.getOwnPropertyDescriptor(n, s))
                }
              }
            })(n),
            $t(n, 'created'),
            n.$options.el && n.$mount(n.$options.el)
        }
      })(Jn),
        (function (e) {
          Object.defineProperty(e.prototype, '$data', {
            get: function () {
              return this._data
            },
          }),
            Object.defineProperty(e.prototype, '$props', {
              get: function () {
                return this._props
              },
            }),
            (e.prototype.$set = Ie),
            (e.prototype.$delete = Pe),
            (e.prototype.$watch = function (e, t, n) {
              var a = this
              if (l(t)) return kn(a, e, t, n)
              ;(n = n || {}).user = !0
              var i = new mn(a, e, t, n)
              if (n.immediate) {
                var r = 'callback for immediate watcher "'.concat(i.expression, '"')
                ge(), Xt(t, a, [i.value], a, r), we()
              }
              return function () {
                i.teardown()
              }
            })
        })(Jn),
        (function (e) {
          var n = /^hook:/
          ;(e.prototype.$on = function (e, a) {
            var i = this
            if (t(e)) for (var r = 0, s = e.length; r < s; r++) i.$on(e[r], a)
            else (i._events[e] || (i._events[e] = [])).push(a), n.test(e) && (i._hasHookEvent = !0)
            return i
          }),
            (e.prototype.$once = function (e, t) {
              var n = this
              function a() {
                n.$off(e, a), t.apply(n, arguments)
              }
              return (a.fn = t), n.$on(e, a), n
            }),
            (e.prototype.$off = function (e, n) {
              var a = this
              if (!arguments.length) return (a._events = Object.create(null)), a
              if (t(e)) {
                for (var i = 0, r = e.length; i < r; i++) a.$off(e[i], n)
                return a
              }
              var s,
                o = a._events[e]
              if (!o) return a
              if (!n) return (a._events[e] = null), a
              for (var u = o.length; u--; )
                if ((s = o[u]) === n || s.fn === n) {
                  o.splice(u, 1)
                  break
                }
              return a
            }),
            (e.prototype.$emit = function (e) {
              var t = this,
                n = t._events[e]
              if (n) {
                n = n.length > 1 ? R(n) : n
                for (var a = R(arguments, 1), i = 'event handler for "'.concat(e, '"'), r = 0, s = n.length; r < s; r++)
                  Xt(n[r], t, a, t, i)
              }
              return t
            })
        })(Jn),
        (function (e) {
          ;(e.prototype._update = function (e, t) {
            var n = this,
              a = n.$el,
              i = n._vnode,
              r = It(n)
            ;(n._vnode = e),
              (n.$el = i ? n.__patch__(i, e) : n.__patch__(n.$el, e, t, !1)),
              r(),
              a && (a.__vue__ = null),
              n.$el && (n.$el.__vue__ = n)
            for (var s = n; s && s.$vnode && s.$parent && s.$vnode === s.$parent._vnode; )
              (s.$parent.$el = s.$el), (s = s.$parent)
          }),
            (e.prototype.$forceUpdate = function () {
              this._watcher && this._watcher.update()
            }),
            (e.prototype.$destroy = function () {
              var e = this
              if (!e._isBeingDestroyed) {
                $t(e, 'beforeDestroy'), (e._isBeingDestroyed = !0)
                var t = e.$parent
                !t || t._isBeingDestroyed || e.$options.abstract || b(t.$children, e),
                  e._scope.stop(),
                  e._data.__ob__ && e._data.__ob__.vmCount--,
                  (e._isDestroyed = !0),
                  e.__patch__(e._vnode, null),
                  $t(e, 'destroyed'),
                  e.$off(),
                  e.$el && (e.$el.__vue__ = null),
                  e.$vnode && (e.$vnode.parent = null)
              }
            })
        })(Jn),
        (function (e) {
          dt(e.prototype),
            (e.prototype.$nextTick = function (e) {
              return pn(e, this)
            }),
            (e.prototype._render = function () {
              var e = this,
                n = e.$options,
                a = n.render,
                i = n._parentVnode
              i &&
                e._isMounted &&
                ((e.$scopedSlots = mt(e.$parent, i.data.scopedSlots, e.$slots, e.$scopedSlots)),
                e._slotsProxy && gt(e._slotsProxy, e.$scopedSlots)),
                (e.$vnode = i)
              var r,
                s = pe,
                o = kt
              try {
                le(e), (kt = e), (r = a.call(e._renderProxy, e.$createElement))
              } catch (t) {
                Jt(t, e, 'render'), (r = e._vnode)
              } finally {
                ;(kt = o), le(s)
              }
              return t(r) && 1 === r.length && (r = r[0]), r instanceof de || (r = ce()), (r.parent = i), r
            })
        })(Jn)
      var ea = [String, RegExp, Array],
        ta = {
          KeepAlive: {
            name: 'keep-alive',
            abstract: !0,
            props: { include: ea, exclude: ea, max: [String, Number] },
            methods: {
              cacheVNode: function () {
                var e = this,
                  t = e.cache,
                  n = e.keys,
                  a = e.vnodeToCache,
                  i = e.keyToCache
                if (a) {
                  var r = a.tag,
                    s = a.componentInstance,
                    o = a.componentOptions
                  ;(t[i] = { name: Xn(o), tag: r, componentInstance: s }),
                    n.push(i),
                    this.max && n.length > parseInt(this.max) && Qn(t, n[0], n, this._vnode),
                    (this.vnodeToCache = null)
                }
              },
            },
            created: function () {
              ;(this.cache = Object.create(null)), (this.keys = [])
            },
            destroyed: function () {
              for (var e in this.cache) Qn(this.cache, e, this.keys)
            },
            mounted: function () {
              var e = this
              this.cacheVNode(),
                this.$watch('include', function (t) {
                  Zn(e, function (e) {
                    return Yn(t, e)
                  })
                }),
                this.$watch('exclude', function (t) {
                  Zn(e, function (e) {
                    return !Yn(t, e)
                  })
                })
            },
            updated: function () {
              this.cacheVNode()
            },
            render: function () {
              var e = this.$slots.default,
                t = Mt(e),
                n = t && t.componentOptions
              if (n) {
                var a = Xn(n),
                  i = this.include,
                  r = this.exclude
                if ((i && (!a || !Yn(i, a))) || (r && a && Yn(r, a))) return t
                var s = this.cache,
                  o = this.keys,
                  u = null == t.key ? n.Ctor.cid + (n.tag ? '::'.concat(n.tag) : '') : t.key
                s[u]
                  ? ((t.componentInstance = s[u].componentInstance), b(o, u), o.push(u))
                  : ((this.vnodeToCache = t), (this.keyToCache = u)),
                  (t.data.keepAlive = !0)
              }
              return t || (e && e[0])
            },
          },
        }
      !(function (e) {
        var t = {
          get: function () {
            return F
          },
        }
        Object.defineProperty(e, 'config', t),
          (e.util = { warn: Un, extend: O, mergeOptions: Wn, defineReactive: Ee }),
          (e.set = Ie),
          (e.delete = Pe),
          (e.nextTick = pn),
          (e.observable = function (e) {
            return Oe(e), e
          }),
          (e.options = Object.create(null)),
          N.forEach(function (t) {
            e.options[t + 's'] = Object.create(null)
          }),
          (e.options._base = e),
          O(e.options.components, ta),
          (function (e) {
            e.use = function (e) {
              var t = this._installedPlugins || (this._installedPlugins = [])
              if (t.indexOf(e) > -1) return this
              var n = R(arguments, 1)
              return n.unshift(this), o(e.install) ? e.install.apply(e, n) : o(e) && e.apply(null, n), t.push(e), this
            }
          })(e),
          (function (e) {
            e.mixin = function (e) {
              return (this.options = Wn(this.options, e)), this
            }
          })(e),
          (function (e) {
            e.cid = 0
            var t = 1
            e.extend = function (e) {
              e = e || {}
              var n = this,
                a = n.cid,
                i = e._Ctor || (e._Ctor = {})
              if (i[a]) return i[a]
              var r = On(e) || On(n.options),
                s = function (e) {
                  this._init(e)
                }
              return (
                ((s.prototype = Object.create(n.prototype)).constructor = s),
                (s.cid = t++),
                (s.options = Wn(n.options, e)),
                (s.super = n),
                s.options.props &&
                  (function (e) {
                    var t = e.options.props
                    for (var n in t) vn(e.prototype, '_props', n)
                  })(s),
                s.options.computed &&
                  (function (e) {
                    var t = e.options.computed
                    for (var n in t) gn(e.prototype, n, t[n])
                  })(s),
                (s.extend = n.extend),
                (s.mixin = n.mixin),
                (s.use = n.use),
                N.forEach(function (e) {
                  s[e] = n[e]
                }),
                r && (s.options.components[r] = s),
                (s.superOptions = n.options),
                (s.extendOptions = e),
                (s.sealedOptions = O({}, s.options)),
                (i[a] = s),
                s
              )
            }
          })(e),
          (function (e) {
            N.forEach(function (t) {
              e[t] = function (e, n) {
                return n
                  ? ('component' === t && l(n) && ((n.name = n.name || e), (n = this.options._base.extend(n))),
                    'directive' === t && o(n) && (n = { bind: n, update: n }),
                    (this.options[t + 's'][e] = n),
                    n)
                  : this.options[t + 's'][e]
              }
            })
          })(e)
      })(Jn),
        Object.defineProperty(Jn.prototype, '$isServer', { get: ie }),
        Object.defineProperty(Jn.prototype, '$ssrContext', {
          get: function () {
            return this.$vnode && this.$vnode.ssrContext
          },
        }),
        Object.defineProperty(Jn, 'FunctionalRenderContext', { value: Sn }),
        (Jn.version = '2.7.16')
      var na = h('style,class'),
        aa = h('input,textarea,option,select,progress'),
        ia = function (e, t, n) {
          return (
            ('value' === n && aa(e) && 'button' !== t) ||
            ('selected' === n && 'option' === e) ||
            ('checked' === n && 'input' === e) ||
            ('muted' === n && 'video' === e)
          )
        },
        ra = h('contenteditable,draggable,spellcheck'),
        sa = h('events,caret,typing,plaintext-only'),
        oa = function (e, t) {
          return ca(t) || 'false' === t ? 'false' : 'contenteditable' === e && sa(t) ? t : 'true'
        },
        ua = h(
          'allowfullscreen,async,autofocus,autoplay,checked,compact,controls,declare,default,defaultchecked,defaultmuted,defaultselected,defer,disabled,enabled,formnovalidate,hidden,indeterminate,inert,ismap,itemscope,loop,multiple,muted,nohref,noresize,noshade,novalidate,nowrap,open,pauseonexit,readonly,required,reversed,scoped,seamless,selected,sortable,truespeed,typemustmatch,visible'
        ),
        pa = 'http://www.w3.org/1999/xlink',
        la = function (e) {
          return ':' === e.charAt(5) && 'xlink' === e.slice(0, 5)
        },
        da = function (e) {
          return la(e) ? e.slice(6, e.length) : ''
        },
        ca = function (e) {
          return null == e || !1 === e
        }
      function ya(e, t) {
        return { staticClass: fa(e.staticClass, t.staticClass), class: i(e.class) ? [e.class, t.class] : t.class }
      }
      function fa(e, t) {
        return e ? (t ? e + ' ' + t : e) : t || ''
      }
      function ma(e) {
        return Array.isArray(e)
          ? (function (e) {
              for (var t, n = '', a = 0, r = e.length; a < r; a++)
                i((t = ma(e[a]))) && '' !== t && (n && (n += ' '), (n += t))
              return n
            })(e)
          : u(e)
          ? (function (e) {
              var t = ''
              for (var n in e) e[n] && (t && (t += ' '), (t += n))
              return t
            })(e)
          : 'string' == typeof e
          ? e
          : ''
      }
      var ha = { svg: 'http://www.w3.org/2000/svg', math: 'http://www.w3.org/1998/Math/MathML' },
        va = h(
          'html,body,base,head,link,meta,style,title,address,article,aside,footer,header,h1,h2,h3,h4,h5,h6,hgroup,nav,section,div,dd,dl,dt,figcaption,figure,picture,hr,img,li,main,ol,p,pre,ul,a,b,abbr,bdi,bdo,br,cite,code,data,dfn,em,i,kbd,mark,q,rp,rt,rtc,ruby,s,samp,small,span,strong,sub,sup,time,u,var,wbr,area,audio,map,track,video,embed,object,param,source,canvas,script,noscript,del,ins,caption,col,colgroup,table,thead,tbody,td,th,tr,button,datalist,fieldset,form,input,label,legend,meter,optgroup,option,output,progress,select,textarea,details,dialog,menu,menuitem,summary,content,element,shadow,template,blockquote,iframe,tfoot'
        ),
        Ta = h(
          'svg,animate,circle,clippath,cursor,defs,desc,ellipse,filter,font-face,foreignobject,g,glyph,image,line,marker,mask,missing-glyph,path,pattern,polygon,polyline,rect,switch,symbol,text,textpath,tspan,use,view',
          !0
        ),
        ba = function (e) {
          return va(e) || Ta(e)
        }
      function ga(e) {
        return Ta(e) ? 'svg' : 'math' === e ? 'math' : void 0
      }
      var wa = Object.create(null),
        _a = h('text,number,password,search,email,tel,url')
      function ka(e) {
        return 'string' == typeof e ? document.querySelector(e) || document.createElement('div') : e
      }
      var Aa = Object.freeze({
          __proto__: null,
          createElement: function (e, t) {
            var n = document.createElement(e)
            return (
              'select' !== e ||
                (t.data && t.data.attrs && void 0 !== t.data.attrs.multiple && n.setAttribute('multiple', 'multiple')),
              n
            )
          },
          createElementNS: function (e, t) {
            return document.createElementNS(ha[e], t)
          },
          createTextNode: function (e) {
            return document.createTextNode(e)
          },
          createComment: function (e) {
            return document.createComment(e)
          },
          insertBefore: function (e, t, n) {
            e.insertBefore(t, n)
          },
          removeChild: function (e, t) {
            e.removeChild(t)
          },
          appendChild: function (e, t) {
            e.appendChild(t)
          },
          parentNode: function (e) {
            return e.parentNode
          },
          nextSibling: function (e) {
            return e.nextSibling
          },
          tagName: function (e) {
            return e.tagName
          },
          setTextContent: function (e, t) {
            e.textContent = t
          },
          setStyleScope: function (e, t) {
            e.setAttribute(t, '')
          },
        }),
        Ma = {
          create: function (e, t) {
            Ca(t)
          },
          update: function (e, t) {
            e.data.ref !== t.data.ref && (Ca(e, !0), Ca(t))
          },
          destroy: function (e) {
            Ca(e, !0)
          },
        }
      function Ca(e, n) {
        var a = e.data.ref
        if (i(a)) {
          var r = e.context,
            s = e.componentInstance || e.elm,
            u = n ? null : s,
            p = n ? void 0 : s
          if (o(a)) Xt(a, r, [u], r, 'template ref function')
          else {
            var l = e.data.refInFor,
              d = 'string' == typeof a || 'number' == typeof a,
              c = De(a),
              y = r.$refs
            if (d || c)
              if (l) {
                var f = d ? y[a] : a.value
                n
                  ? t(f) && b(f, s)
                  : t(f)
                  ? f.includes(s) || f.push(s)
                  : d
                  ? ((y[a] = [s]), Sa(r, a, y[a]))
                  : (a.value = [s])
              } else if (d) {
                if (n && y[a] !== s) return
                ;(y[a] = p), Sa(r, a, u)
              } else if (c) {
                if (n && a.value !== s) return
                a.value = u
              }
          }
        }
      }
      function Sa(e, t, n) {
        var a = e._setupState
        a && w(a, t) && (De(a[t]) ? (a[t].value = n) : (a[t] = n))
      }
      var xa = new de('', {}, []),
        Ra = ['create', 'activate', 'update', 'remove', 'destroy']
      function Oa(e, t) {
        return (
          e.key === t.key &&
          e.asyncFactory === t.asyncFactory &&
          ((e.tag === t.tag &&
            e.isComment === t.isComment &&
            i(e.data) === i(t.data) &&
            (function (e, t) {
              if ('input' !== e.tag) return !0
              var n,
                a = i((n = e.data)) && i((n = n.attrs)) && n.type,
                r = i((n = t.data)) && i((n = n.attrs)) && n.type
              return a === r || (_a(a) && _a(r))
            })(e, t)) ||
            (r(e.isAsyncPlaceholder) && a(t.asyncFactory.error)))
        )
      }
      function Ea(e, t, n) {
        var a,
          r,
          s = {}
        for (a = t; a <= n; ++a) i((r = e[a].key)) && (s[r] = a)
        return s
      }
      var Ia = {
        create: Pa,
        update: Pa,
        destroy: function (e) {
          Pa(e, xa)
        },
      }
      function Pa(e, t) {
        ;(e.data.directives || t.data.directives) &&
          (function (e, t) {
            var n,
              a,
              i,
              r = e === xa,
              s = t === xa,
              o = Ua(e.data.directives, e.context),
              u = Ua(t.data.directives, t.context),
              p = [],
              l = []
            for (n in u)
              (a = o[n]),
                (i = u[n]),
                a
                  ? ((i.oldValue = a.value),
                    (i.oldArg = a.arg),
                    Da(i, 'update', t, e),
                    i.def && i.def.componentUpdated && l.push(i))
                  : (Da(i, 'bind', t, e), i.def && i.def.inserted && p.push(i))
            if (p.length) {
              var d = function () {
                for (var n = 0; n < p.length; n++) Da(p[n], 'inserted', t, e)
              }
              r ? We(t, 'insert', d) : d()
            }
            if (
              (l.length &&
                We(t, 'postpatch', function () {
                  for (var n = 0; n < l.length; n++) Da(l[n], 'componentUpdated', t, e)
                }),
              !r)
            )
              for (n in o) u[n] || Da(o[n], 'unbind', e, e, s)
          })(e, t)
      }
      var Ba = Object.create(null)
      function Ua(e, t) {
        var n,
          a,
          i = Object.create(null)
        if (!e) return i
        for (n = 0; n < e.length; n++) {
          if (((a = e[n]).modifiers || (a.modifiers = Ba), (i[$a(a)] = a), t._setupState && t._setupState.__sfc)) {
            var r = a.def || Ln(t, '_setupState', 'v-' + a.name)
            a.def = 'function' == typeof r ? { bind: r, update: r } : r
          }
          a.def = a.def || Ln(t.$options, 'directives', a.name)
        }
        return i
      }
      function $a(e) {
        return e.rawName || ''.concat(e.name, '.').concat(Object.keys(e.modifiers || {}).join('.'))
      }
      function Da(e, t, n, a, i) {
        var r = e.def && e.def[t]
        if (r)
          try {
            r(n.elm, e, n, a, i)
          } catch (a) {
            Jt(a, n.context, 'directive '.concat(e.name, ' ').concat(t, ' hook'))
          }
      }
      var Va = [Ma, Ia]
      function Na(e, t) {
        var n = t.componentOptions
        if (!((i(n) && !1 === n.Ctor.options.inheritAttrs) || (a(e.data.attrs) && a(t.data.attrs)))) {
          var s,
            o,
            u = t.elm,
            p = e.data.attrs || {},
            l = t.data.attrs || {}
          for (s in ((i(l.__ob__) || r(l._v_attr_proxy)) && (l = t.data.attrs = O({}, l)), l))
            (o = l[s]), p[s] !== o && ja(u, s, o, t.data.pre)
          for (s in ((J || Y) && l.value !== p.value && ja(u, 'value', l.value), p))
            a(l[s]) && (la(s) ? u.removeAttributeNS(pa, da(s)) : ra(s) || u.removeAttribute(s))
        }
      }
      function ja(e, t, n, a) {
        a || e.tagName.indexOf('-') > -1
          ? Fa(e, t, n)
          : ua(t)
          ? ca(n)
            ? e.removeAttribute(t)
            : ((n = 'allowfullscreen' === t && 'EMBED' === e.tagName ? 'true' : t), e.setAttribute(t, n))
          : ra(t)
          ? e.setAttribute(t, oa(t, n))
          : la(t)
          ? ca(n)
            ? e.removeAttributeNS(pa, da(t))
            : e.setAttributeNS(pa, t, n)
          : Fa(e, t, n)
      }
      function Fa(e, t, n) {
        if (ca(n)) e.removeAttribute(t)
        else {
          if (J && !X && 'TEXTAREA' === e.tagName && 'placeholder' === t && '' !== n && !e.__ieph) {
            var a = function (t) {
              t.stopImmediatePropagation(), e.removeEventListener('input', a)
            }
            e.addEventListener('input', a), (e.__ieph = !0)
          }
          e.setAttribute(t, n)
        }
      }
      var Wa = { create: Na, update: Na }
      function La(e, t) {
        var n = t.elm,
          r = t.data,
          s = e.data
        if (!(a(r.staticClass) && a(r.class) && (a(s) || (a(s.staticClass) && a(s.class))))) {
          var o = (function (e) {
              for (var t = e.data, n = e, a = e; i(a.componentInstance); )
                (a = a.componentInstance._vnode) && a.data && (t = ya(a.data, t))
              for (; i((n = n.parent)); ) n && n.data && (t = ya(t, n.data))
              return (r = t.staticClass), (s = t.class), i(r) || i(s) ? fa(r, ma(s)) : ''
              var r, s
            })(t),
            u = n._transitionClasses
          i(u) && (o = fa(o, ma(u))), o !== n._prevClass && (n.setAttribute('class', o), (n._prevClass = o))
        }
      }
      var qa,
        za,
        Ha,
        Ga,
        Ka,
        Ja,
        Xa = { create: La, update: La },
        Ya = /[\w).+\-_$\]]/
      function Za(e) {
        var t,
          n,
          a,
          i,
          r,
          s = !1,
          o = !1,
          u = !1,
          p = !1,
          l = 0,
          d = 0,
          c = 0,
          y = 0
        for (a = 0; a < e.length; a++)
          if (((n = t), (t = e.charCodeAt(a)), s)) 39 === t && 92 !== n && (s = !1)
          else if (o) 34 === t && 92 !== n && (o = !1)
          else if (u) 96 === t && 92 !== n && (u = !1)
          else if (p) 47 === t && 92 !== n && (p = !1)
          else if (124 !== t || 124 === e.charCodeAt(a + 1) || 124 === e.charCodeAt(a - 1) || l || d || c) {
            switch (t) {
              case 34:
                o = !0
                break
              case 39:
                s = !0
                break
              case 96:
                u = !0
                break
              case 40:
                c++
                break
              case 41:
                c--
                break
              case 91:
                d++
                break
              case 93:
                d--
                break
              case 123:
                l++
                break
              case 125:
                l--
            }
            if (47 === t) {
              for (var f = a - 1, m = void 0; f >= 0 && ' ' === (m = e.charAt(f)); f--);
              ;(m && Ya.test(m)) || (p = !0)
            }
          } else void 0 === i ? ((y = a + 1), (i = e.slice(0, a).trim())) : h()
        function h() {
          ;(r || (r = [])).push(e.slice(y, a).trim()), (y = a + 1)
        }
        if ((void 0 === i ? (i = e.slice(0, a).trim()) : 0 !== y && h(), r))
          for (a = 0; a < r.length; a++) i = Qa(i, r[a])
        return i
      }
      function Qa(e, t) {
        var n = t.indexOf('(')
        if (n < 0) return '_f("'.concat(t, '")(').concat(e, ')')
        var a = t.slice(0, n),
          i = t.slice(n + 1)
        return '_f("'
          .concat(a, '")(')
          .concat(e)
          .concat(')' !== i ? ',' + i : i)
      }
      function ei(e, t) {
        console.error('[Vue compiler]: '.concat(e))
      }
      function ti(e, t) {
        return e
          ? e
              .map(function (e) {
                return e[t]
              })
              .filter(function (e) {
                return e
              })
          : []
      }
      function ni(e, t, n, a, i) {
        ;(e.props || (e.props = [])).push(di({ name: t, value: n, dynamic: i }, a)), (e.plain = !1)
      }
      function ai(e, t, n, a, i) {
        ;(i ? e.dynamicAttrs || (e.dynamicAttrs = []) : e.attrs || (e.attrs = [])).push(
          di({ name: t, value: n, dynamic: i }, a)
        ),
          (e.plain = !1)
      }
      function ii(e, t, n, a) {
        ;(e.attrsMap[t] = n), e.attrsList.push(di({ name: t, value: n }, a))
      }
      function ri(e, t, n, a, i, r, s, o) {
        ;(e.directives || (e.directives = [])).push(
          di({ name: t, rawName: n, value: a, arg: i, isDynamicArg: r, modifiers: s }, o)
        ),
          (e.plain = !1)
      }
      function si(e, t, n) {
        return n ? '_p('.concat(t, ',"').concat(e, '")') : e + t
      }
      function oi(t, n, a, i, r, s, o, u) {
        var p
        ;(i = i || e).right
          ? u
            ? (n = '('.concat(n, ")==='click'?'contextmenu':(").concat(n, ')'))
            : 'click' === n && ((n = 'contextmenu'), delete i.right)
          : i.middle &&
            (u ? (n = '('.concat(n, ")==='click'?'mouseup':(").concat(n, ')')) : 'click' === n && (n = 'mouseup')),
          i.capture && (delete i.capture, (n = si('!', n, u))),
          i.once && (delete i.once, (n = si('~', n, u))),
          i.passive && (delete i.passive, (n = si('&', n, u))),
          i.native
            ? (delete i.native, (p = t.nativeEvents || (t.nativeEvents = {})))
            : (p = t.events || (t.events = {}))
        var l = di({ value: a.trim(), dynamic: u }, o)
        i !== e && (l.modifiers = i)
        var d = p[n]
        Array.isArray(d) ? (r ? d.unshift(l) : d.push(l)) : (p[n] = d ? (r ? [l, d] : [d, l]) : l), (t.plain = !1)
      }
      function ui(e, t, n) {
        var a = pi(e, ':' + t) || pi(e, 'v-bind:' + t)
        if (null != a) return Za(a)
        if (!1 !== n) {
          var i = pi(e, t)
          if (null != i) return JSON.stringify(i)
        }
      }
      function pi(e, t, n) {
        var a
        if (null != (a = e.attrsMap[t]))
          for (var i = e.attrsList, r = 0, s = i.length; r < s; r++)
            if (i[r].name === t) {
              i.splice(r, 1)
              break
            }
        return n && delete e.attrsMap[t], a
      }
      function li(e, t) {
        for (var n = e.attrsList, a = 0, i = n.length; a < i; a++) {
          var r = n[a]
          if (t.test(r.name)) return n.splice(a, 1), r
        }
      }
      function di(e, t) {
        return t && (null != t.start && (e.start = t.start), null != t.end && (e.end = t.end)), e
      }
      function ci(e, t, n) {
        var a = n || {},
          i = a.number,
          r = '$$v',
          s = r
        a.trim && (s = '(typeof '.concat(r, " === 'string'") + '? '.concat(r, '.trim()') + ': '.concat(r, ')')),
          i && (s = '_n('.concat(s, ')'))
        var o = yi(t, s)
        e.model = {
          value: '('.concat(t, ')'),
          expression: JSON.stringify(t),
          callback: 'function ('.concat(r, ') {').concat(o, '}'),
        }
      }
      function yi(e, t) {
        var n = (function (e) {
          if (((e = e.trim()), (qa = e.length), e.indexOf('[') < 0 || e.lastIndexOf(']') < qa - 1))
            return (Ga = e.lastIndexOf('.')) > -1
              ? { exp: e.slice(0, Ga), key: '"' + e.slice(Ga + 1) + '"' }
              : { exp: e, key: null }
          for (za = e, Ga = Ka = Ja = 0; !mi(); ) hi((Ha = fi())) ? Ti(Ha) : 91 === Ha && vi(Ha)
          return { exp: e.slice(0, Ka), key: e.slice(Ka + 1, Ja) }
        })(e)
        return null === n.key
          ? ''.concat(e, '=').concat(t)
          : '$set('.concat(n.exp, ', ').concat(n.key, ', ').concat(t, ')')
      }
      function fi() {
        return za.charCodeAt(++Ga)
      }
      function mi() {
        return Ga >= qa
      }
      function hi(e) {
        return 34 === e || 39 === e
      }
      function vi(e) {
        var t = 1
        for (Ka = Ga; !mi(); )
          if (hi((e = fi()))) Ti(e)
          else if ((91 === e && t++, 93 === e && t--, 0 === t)) {
            Ja = Ga
            break
          }
      }
      function Ti(e) {
        for (var t = e; !mi() && (e = fi()) !== t; );
      }
      var bi,
        gi = '__r',
        wi = '__c'
      function _i(e, t, n) {
        var a = bi
        return function i() {
          null !== t.apply(null, arguments) && Mi(e, i, n, a)
        }
      }
      var ki = en && !(ee && Number(ee[1]) <= 53)
      function Ai(e, t, n, a) {
        if (ki) {
          var i = Lt,
            r = t
          t = r._wrapper = function (e) {
            if (
              e.target === e.currentTarget ||
              e.timeStamp >= i ||
              e.timeStamp <= 0 ||
              e.target.ownerDocument !== document
            )
              return r.apply(this, arguments)
          }
        }
        bi.addEventListener(e, t, ne ? { capture: n, passive: a } : n)
      }
      function Mi(e, t, n, a) {
        ;(a || bi).removeEventListener(e, t._wrapper || t, n)
      }
      function Ci(e, t) {
        if (!a(e.data.on) || !a(t.data.on)) {
          var n = t.data.on || {},
            r = e.data.on || {}
          ;(bi = t.elm || e.elm),
            (function (e) {
              if (i(e[gi])) {
                var t = J ? 'change' : 'input'
                ;(e[t] = [].concat(e[gi], e[t] || [])), delete e[gi]
              }
              i(e[wi]) && ((e.change = [].concat(e[wi], e.change || [])), delete e[wi])
            })(n),
            Fe(n, r, Ai, Mi, _i, t.context),
            (bi = void 0)
        }
      }
      var Si,
        xi = {
          create: Ci,
          update: Ci,
          destroy: function (e) {
            return Ci(e, xa)
          },
        }
      function Ri(e, t) {
        if (!a(e.data.domProps) || !a(t.data.domProps)) {
          var n,
            s,
            o = t.elm,
            u = e.data.domProps || {},
            p = t.data.domProps || {}
          for (n in ((i(p.__ob__) || r(p._v_attr_proxy)) && (p = t.data.domProps = O({}, p)), u)) n in p || (o[n] = '')
          for (n in p) {
            if (((s = p[n]), 'textContent' === n || 'innerHTML' === n)) {
              if ((t.children && (t.children.length = 0), s === u[n])) continue
              1 === o.childNodes.length && o.removeChild(o.childNodes[0])
            }
            if ('value' === n && 'PROGRESS' !== o.tagName) {
              o._value = s
              var l = a(s) ? '' : String(s)
              Oi(o, l) && (o.value = l)
            } else if ('innerHTML' === n && Ta(o.tagName) && a(o.innerHTML)) {
              ;(Si = Si || document.createElement('div')).innerHTML = '<svg>'.concat(s, '</svg>')
              for (var d = Si.firstChild; o.firstChild; ) o.removeChild(o.firstChild)
              for (; d.firstChild; ) o.appendChild(d.firstChild)
            } else if (s !== u[n])
              try {
                o[n] = s
              } catch (e) {}
          }
        }
      }
      function Oi(e, t) {
        return (
          !e.composing &&
          ('OPTION' === e.tagName ||
            (function (e, t) {
              var n = !0
              try {
                n = document.activeElement !== e
              } catch (e) {}
              return n && e.value !== t
            })(e, t) ||
            (function (e, t) {
              var n = e.value,
                a = e._vModifiers
              if (i(a)) {
                if (a.number) return m(n) !== m(t)
                if (a.trim) return n.trim() !== t.trim()
              }
              return n !== t
            })(e, t))
        )
      }
      var Ei = { create: Ri, update: Ri },
        Ii = _(function (e) {
          var t = {},
            n = /:(.+)/
          return (
            e.split(/;(?![^(]*\))/g).forEach(function (e) {
              if (e) {
                var a = e.split(n)
                a.length > 1 && (t[a[0].trim()] = a[1].trim())
              }
            }),
            t
          )
        })
      function Pi(e) {
        var t = Bi(e.style)
        return e.staticStyle ? O(e.staticStyle, t) : t
      }
      function Bi(e) {
        return Array.isArray(e) ? E(e) : 'string' == typeof e ? Ii(e) : e
      }
      var Ui,
        $i = /^--/,
        Di = /\s*!important$/,
        Vi = function (e, t, n) {
          if ($i.test(t)) e.style.setProperty(t, n)
          else if (Di.test(n)) e.style.setProperty(S(t), n.replace(Di, ''), 'important')
          else {
            var a = ji(t)
            if (Array.isArray(n)) for (var i = 0, r = n.length; i < r; i++) e.style[a] = n[i]
            else e.style[a] = n
          }
        },
        Ni = ['Webkit', 'Moz', 'ms'],
        ji = _(function (e) {
          if (((Ui = Ui || document.createElement('div').style), 'filter' !== (e = A(e)) && e in Ui)) return e
          for (var t = e.charAt(0).toUpperCase() + e.slice(1), n = 0; n < Ni.length; n++) {
            var a = Ni[n] + t
            if (a in Ui) return a
          }
        })
      function Fi(e, t) {
        var n = t.data,
          r = e.data
        if (!(a(n.staticStyle) && a(n.style) && a(r.staticStyle) && a(r.style))) {
          var s,
            o,
            u = t.elm,
            p = r.staticStyle,
            l = r.normalizedStyle || r.style || {},
            d = p || l,
            c = Bi(t.data.style) || {}
          t.data.normalizedStyle = i(c.__ob__) ? O({}, c) : c
          var y = (function (e, t) {
            for (var n, a = {}, i = e; i.componentInstance; )
              (i = i.componentInstance._vnode) && i.data && (n = Pi(i.data)) && O(a, n)
            ;(n = Pi(e.data)) && O(a, n)
            for (var r = e; (r = r.parent); ) r.data && (n = Pi(r.data)) && O(a, n)
            return a
          })(t)
          for (o in d) a(y[o]) && Vi(u, o, '')
          for (o in y) (s = y[o]), Vi(u, o, null == s ? '' : s)
        }
      }
      var Wi = { create: Fi, update: Fi },
        Li = /\s+/
      function qi(e, t) {
        if (t && (t = t.trim()))
          if (e.classList)
            t.indexOf(' ') > -1
              ? t.split(Li).forEach(function (t) {
                  return e.classList.add(t)
                })
              : e.classList.add(t)
          else {
            var n = ' '.concat(e.getAttribute('class') || '', ' ')
            n.indexOf(' ' + t + ' ') < 0 && e.setAttribute('class', (n + t).trim())
          }
      }
      function zi(e, t) {
        if (t && (t = t.trim()))
          if (e.classList)
            t.indexOf(' ') > -1
              ? t.split(Li).forEach(function (t) {
                  return e.classList.remove(t)
                })
              : e.classList.remove(t),
              e.classList.length || e.removeAttribute('class')
          else {
            for (var n = ' '.concat(e.getAttribute('class') || '', ' '), a = ' ' + t + ' '; n.indexOf(a) >= 0; )
              n = n.replace(a, ' ')
            ;(n = n.trim()) ? e.setAttribute('class', n) : e.removeAttribute('class')
          }
      }
      function Hi(e) {
        if (e) {
          if ('object' == typeof e) {
            var t = {}
            return !1 !== e.css && O(t, Gi(e.name || 'v')), O(t, e), t
          }
          return 'string' == typeof e ? Gi(e) : void 0
        }
      }
      var Gi = _(function (e) {
          return {
            enterClass: ''.concat(e, '-enter'),
            enterToClass: ''.concat(e, '-enter-to'),
            enterActiveClass: ''.concat(e, '-enter-active'),
            leaveClass: ''.concat(e, '-leave'),
            leaveToClass: ''.concat(e, '-leave-to'),
            leaveActiveClass: ''.concat(e, '-leave-active'),
          }
        }),
        Ki = G && !X,
        Ji = 'transition',
        Xi = 'animation',
        Yi = 'transition',
        Zi = 'transitionend',
        Qi = 'animation',
        er = 'animationend'
      Ki &&
        (void 0 === window.ontransitionend &&
          void 0 !== window.onwebkittransitionend &&
          ((Yi = 'WebkitTransition'), (Zi = 'webkitTransitionEnd')),
        void 0 === window.onanimationend &&
          void 0 !== window.onwebkitanimationend &&
          ((Qi = 'WebkitAnimation'), (er = 'webkitAnimationEnd')))
      var tr = G
        ? window.requestAnimationFrame
          ? window.requestAnimationFrame.bind(window)
          : setTimeout
        : function (e) {
            return e()
          }
      function nr(e) {
        tr(function () {
          tr(e)
        })
      }
      function ar(e, t) {
        var n = e._transitionClasses || (e._transitionClasses = [])
        n.indexOf(t) < 0 && (n.push(t), qi(e, t))
      }
      function ir(e, t) {
        e._transitionClasses && b(e._transitionClasses, t), zi(e, t)
      }
      function rr(e, t, n) {
        var a = or(e, t),
          i = a.type,
          r = a.timeout,
          s = a.propCount
        if (!i) return n()
        var o = i === Ji ? Zi : er,
          u = 0,
          p = function () {
            e.removeEventListener(o, l), n()
          },
          l = function (t) {
            t.target === e && ++u >= s && p()
          }
        setTimeout(function () {
          u < s && p()
        }, r + 1),
          e.addEventListener(o, l)
      }
      var sr = /\b(transform|all)(,|$)/
      function or(e, t) {
        var n,
          a = window.getComputedStyle(e),
          i = (a[Yi + 'Delay'] || '').split(', '),
          r = (a[Yi + 'Duration'] || '').split(', '),
          s = ur(i, r),
          o = (a[Qi + 'Delay'] || '').split(', '),
          u = (a[Qi + 'Duration'] || '').split(', '),
          p = ur(o, u),
          l = 0,
          d = 0
        return (
          t === Ji
            ? s > 0 && ((n = Ji), (l = s), (d = r.length))
            : t === Xi
            ? p > 0 && ((n = Xi), (l = p), (d = u.length))
            : (d = (n = (l = Math.max(s, p)) > 0 ? (s > p ? Ji : Xi) : null) ? (n === Ji ? r.length : u.length) : 0),
          { type: n, timeout: l, propCount: d, hasTransform: n === Ji && sr.test(a[Yi + 'Property']) }
        )
      }
      function ur(e, t) {
        for (; e.length < t.length; ) e = e.concat(e)
        return Math.max.apply(
          null,
          t.map(function (t, n) {
            return pr(t) + pr(e[n])
          })
        )
      }
      function pr(e) {
        return 1e3 * Number(e.slice(0, -1).replace(',', '.'))
      }
      function lr(e, t) {
        var n = e.elm
        i(n._leaveCb) && ((n._leaveCb.cancelled = !0), n._leaveCb())
        var r = Hi(e.data.transition)
        if (!a(r) && !i(n._enterCb) && 1 === n.nodeType) {
          for (
            var s = r.css,
              p = r.type,
              l = r.enterClass,
              d = r.enterToClass,
              c = r.enterActiveClass,
              y = r.appearClass,
              f = r.appearToClass,
              h = r.appearActiveClass,
              v = r.beforeEnter,
              T = r.enter,
              b = r.afterEnter,
              g = r.enterCancelled,
              w = r.beforeAppear,
              _ = r.appear,
              k = r.afterAppear,
              A = r.appearCancelled,
              M = r.duration,
              C = Et,
              S = Et.$vnode;
            S && S.parent;

          )
            (C = S.context), (S = S.parent)
          var x = !C._isMounted || !e.isRootInsert
          if (!x || _ || '' === _) {
            var R = x && y ? y : l,
              O = x && h ? h : c,
              E = x && f ? f : d,
              I = (x && w) || v,
              P = x && o(_) ? _ : T,
              B = (x && k) || b,
              U = (x && A) || g,
              $ = m(u(M) ? M.enter : M),
              V = !1 !== s && !X,
              N = yr(P),
              j = (n._enterCb = D(function () {
                V && (ir(n, E), ir(n, O)), j.cancelled ? (V && ir(n, R), U && U(n)) : B && B(n), (n._enterCb = null)
              }))
            e.data.show ||
              We(e, 'insert', function () {
                var t = n.parentNode,
                  a = t && t._pending && t._pending[e.key]
                a && a.tag === e.tag && a.elm._leaveCb && a.elm._leaveCb(), P && P(n, j)
              }),
              I && I(n),
              V &&
                (ar(n, R),
                ar(n, O),
                nr(function () {
                  ir(n, R), j.cancelled || (ar(n, E), N || (cr($) ? setTimeout(j, $) : rr(n, p, j)))
                })),
              e.data.show && (t && t(), P && P(n, j)),
              V || N || j()
          }
        }
      }
      function dr(e, t) {
        var n = e.elm
        i(n._enterCb) && ((n._enterCb.cancelled = !0), n._enterCb())
        var r = Hi(e.data.transition)
        if (a(r) || 1 !== n.nodeType) return t()
        if (!i(n._leaveCb)) {
          var s = r.css,
            o = r.type,
            p = r.leaveClass,
            l = r.leaveToClass,
            d = r.leaveActiveClass,
            c = r.beforeLeave,
            y = r.leave,
            f = r.afterLeave,
            h = r.leaveCancelled,
            v = r.delayLeave,
            T = r.duration,
            b = !1 !== s && !X,
            g = yr(y),
            w = m(u(T) ? T.leave : T),
            _ = (n._leaveCb = D(function () {
              n.parentNode && n.parentNode._pending && (n.parentNode._pending[e.key] = null),
                b && (ir(n, l), ir(n, d)),
                _.cancelled ? (b && ir(n, p), h && h(n)) : (t(), f && f(n)),
                (n._leaveCb = null)
            }))
          v ? v(k) : k()
        }
        function k() {
          _.cancelled ||
            (!e.data.show && n.parentNode && ((n.parentNode._pending || (n.parentNode._pending = {}))[e.key] = e),
            c && c(n),
            b &&
              (ar(n, p),
              ar(n, d),
              nr(function () {
                ir(n, p), _.cancelled || (ar(n, l), g || (cr(w) ? setTimeout(_, w) : rr(n, o, _)))
              })),
            y && y(n, _),
            b || g || _())
        }
      }
      function cr(e) {
        return 'number' == typeof e && !isNaN(e)
      }
      function yr(e) {
        if (a(e)) return !1
        var t = e.fns
        return i(t) ? yr(Array.isArray(t) ? t[0] : t) : (e._length || e.length) > 1
      }
      function fr(e, t) {
        !0 !== t.data.show && lr(t)
      }
      var mr = (function (e) {
        var n,
          o,
          u = {},
          p = e.modules,
          l = e.nodeOps
        for (n = 0; n < Ra.length; ++n)
          for (u[Ra[n]] = [], o = 0; o < p.length; ++o) i(p[o][Ra[n]]) && u[Ra[n]].push(p[o][Ra[n]])
        function d(e) {
          var t = l.parentNode(e)
          i(t) && l.removeChild(t, e)
        }
        function c(e, t, n, a, s, o, p) {
          if (
            (i(e.elm) && i(o) && (e = o[p] = fe(e)),
            (e.isRootInsert = !s),
            !(function (e, t, n, a) {
              var s = e.data
              if (i(s)) {
                var o = i(e.componentInstance) && s.keepAlive
                if ((i((s = s.hook)) && i((s = s.init)) && s(e, !1), i(e.componentInstance)))
                  return (
                    y(e, t),
                    f(n, e.elm, a),
                    r(o) &&
                      (function (e, t, n, a) {
                        for (var r, s = e; s.componentInstance; )
                          if (i((r = (s = s.componentInstance._vnode).data)) && i((r = r.transition))) {
                            for (r = 0; r < u.activate.length; ++r) u.activate[r](xa, s)
                            t.push(s)
                            break
                          }
                        f(n, e.elm, a)
                      })(e, t, n, a),
                    !0
                  )
              }
            })(e, t, n, a))
          ) {
            var d = e.data,
              c = e.children,
              h = e.tag
            i(h)
              ? ((e.elm = e.ns ? l.createElementNS(e.ns, h) : l.createElement(h, e)),
                b(e),
                m(e, c, t),
                i(d) && T(e, t),
                f(n, e.elm, a))
              : r(e.isComment)
              ? ((e.elm = l.createComment(e.text)), f(n, e.elm, a))
              : ((e.elm = l.createTextNode(e.text)), f(n, e.elm, a))
          }
        }
        function y(e, t) {
          i(e.data.pendingInsert) && (t.push.apply(t, e.data.pendingInsert), (e.data.pendingInsert = null)),
            (e.elm = e.componentInstance.$el),
            v(e) ? (T(e, t), b(e)) : (Ca(e), t.push(e))
        }
        function f(e, t, n) {
          i(e) && (i(n) ? l.parentNode(n) === e && l.insertBefore(e, t, n) : l.appendChild(e, t))
        }
        function m(e, n, a) {
          if (t(n)) for (var i = 0; i < n.length; ++i) c(n[i], a, e.elm, null, !0, n, i)
          else s(e.text) && l.appendChild(e.elm, l.createTextNode(String(e.text)))
        }
        function v(e) {
          for (; e.componentInstance; ) e = e.componentInstance._vnode
          return i(e.tag)
        }
        function T(e, t) {
          for (var a = 0; a < u.create.length; ++a) u.create[a](xa, e)
          i((n = e.data.hook)) && (i(n.create) && n.create(xa, e), i(n.insert) && t.push(e))
        }
        function b(e) {
          var t
          if (i((t = e.fnScopeId))) l.setStyleScope(e.elm, t)
          else
            for (var n = e; n; )
              i((t = n.context)) && i((t = t.$options._scopeId)) && l.setStyleScope(e.elm, t), (n = n.parent)
          i((t = Et)) &&
            t !== e.context &&
            t !== e.fnContext &&
            i((t = t.$options._scopeId)) &&
            l.setStyleScope(e.elm, t)
        }
        function g(e, t, n, a, i, r) {
          for (; a <= i; ++a) c(n[a], r, e, t, !1, n, a)
        }
        function w(e) {
          var t,
            n,
            a = e.data
          if (i(a))
            for (i((t = a.hook)) && i((t = t.destroy)) && t(e), t = 0; t < u.destroy.length; ++t) u.destroy[t](e)
          if (i((t = e.children))) for (n = 0; n < e.children.length; ++n) w(e.children[n])
        }
        function _(e, t, n) {
          for (; t <= n; ++t) {
            var a = e[t]
            i(a) && (i(a.tag) ? (k(a), w(a)) : d(a.elm))
          }
        }
        function k(e, t) {
          if (i(t) || i(e.data)) {
            var n,
              a = u.remove.length + 1
            for (
              i(t)
                ? (t.listeners += a)
                : (t = (function (e, t) {
                    function n() {
                      0 == --n.listeners && d(e)
                    }
                    return (n.listeners = t), n
                  })(e.elm, a)),
                i((n = e.componentInstance)) && i((n = n._vnode)) && i(n.data) && k(n, t),
                n = 0;
              n < u.remove.length;
              ++n
            )
              u.remove[n](e, t)
            i((n = e.data.hook)) && i((n = n.remove)) ? n(e, t) : t()
          } else d(e.elm)
        }
        function A(e, t, n, a) {
          for (var r = n; r < a; r++) {
            var s = t[r]
            if (i(s) && Oa(e, s)) return r
          }
        }
        function M(e, t, n, s, o, p) {
          if (e !== t) {
            i(t.elm) && i(s) && (t = s[o] = fe(t))
            var d = (t.elm = e.elm)
            if (r(e.isAsyncPlaceholder)) i(t.asyncFactory.resolved) ? x(e.elm, t, n) : (t.isAsyncPlaceholder = !0)
            else if (r(t.isStatic) && r(e.isStatic) && t.key === e.key && (r(t.isCloned) || r(t.isOnce)))
              t.componentInstance = e.componentInstance
            else {
              var y,
                f = t.data
              i(f) && i((y = f.hook)) && i((y = y.prepatch)) && y(e, t)
              var m = e.children,
                h = t.children
              if (i(f) && v(t)) {
                for (y = 0; y < u.update.length; ++y) u.update[y](e, t)
                i((y = f.hook)) && i((y = y.update)) && y(e, t)
              }
              a(t.text)
                ? i(m) && i(h)
                  ? m !== h &&
                    (function (e, t, n, r, s) {
                      for (
                        var o,
                          u,
                          p,
                          d = 0,
                          y = 0,
                          f = t.length - 1,
                          m = t[0],
                          h = t[f],
                          v = n.length - 1,
                          T = n[0],
                          b = n[v],
                          w = !s;
                        d <= f && y <= v;

                      )
                        a(m)
                          ? (m = t[++d])
                          : a(h)
                          ? (h = t[--f])
                          : Oa(m, T)
                          ? (M(m, T, r, n, y), (m = t[++d]), (T = n[++y]))
                          : Oa(h, b)
                          ? (M(h, b, r, n, v), (h = t[--f]), (b = n[--v]))
                          : Oa(m, b)
                          ? (M(m, b, r, n, v),
                            w && l.insertBefore(e, m.elm, l.nextSibling(h.elm)),
                            (m = t[++d]),
                            (b = n[--v]))
                          : Oa(h, T)
                          ? (M(h, T, r, n, y), w && l.insertBefore(e, h.elm, m.elm), (h = t[--f]), (T = n[++y]))
                          : (a(o) && (o = Ea(t, d, f)),
                            a((u = i(T.key) ? o[T.key] : A(T, t, d, f)))
                              ? c(T, r, e, m.elm, !1, n, y)
                              : Oa((p = t[u]), T)
                              ? (M(p, T, r, n, y), (t[u] = void 0), w && l.insertBefore(e, p.elm, m.elm))
                              : c(T, r, e, m.elm, !1, n, y),
                            (T = n[++y]))
                      d > f ? g(e, a(n[v + 1]) ? null : n[v + 1].elm, n, y, v, r) : y > v && _(t, d, f)
                    })(d, m, h, n, p)
                  : i(h)
                  ? (i(e.text) && l.setTextContent(d, ''), g(d, null, h, 0, h.length - 1, n))
                  : i(m)
                  ? _(m, 0, m.length - 1)
                  : i(e.text) && l.setTextContent(d, '')
                : e.text !== t.text && l.setTextContent(d, t.text),
                i(f) && i((y = f.hook)) && i((y = y.postpatch)) && y(e, t)
            }
          }
        }
        function C(e, t, n) {
          if (r(n) && i(e.parent)) e.parent.data.pendingInsert = t
          else for (var a = 0; a < t.length; ++a) t[a].data.hook.insert(t[a])
        }
        var S = h('attrs,class,staticClass,staticStyle,key')
        function x(e, t, n, a) {
          var s,
            o = t.tag,
            u = t.data,
            p = t.children
          if (((a = a || (u && u.pre)), (t.elm = e), r(t.isComment) && i(t.asyncFactory)))
            return (t.isAsyncPlaceholder = !0), !0
          if (i(u) && (i((s = u.hook)) && i((s = s.init)) && s(t, !0), i((s = t.componentInstance)))) return y(t, n), !0
          if (i(o)) {
            if (i(p))
              if (e.hasChildNodes())
                if (i((s = u)) && i((s = s.domProps)) && i((s = s.innerHTML))) {
                  if (s !== e.innerHTML) return !1
                } else {
                  for (var l = !0, d = e.firstChild, c = 0; c < p.length; c++) {
                    if (!d || !x(d, p[c], n, a)) {
                      l = !1
                      break
                    }
                    d = d.nextSibling
                  }
                  if (!l || d) return !1
                }
              else m(t, p, n)
            if (i(u)) {
              var f = !1
              for (var h in u)
                if (!S(h)) {
                  ;(f = !0), T(t, n)
                  break
                }
              !f && u.class && cn(u.class)
            }
          } else e.data !== t.text && (e.data = t.text)
          return !0
        }
        return function (e, t, n, s) {
          if (!a(t)) {
            var o,
              p = !1,
              d = []
            if (a(e)) (p = !0), c(t, d)
            else {
              var y = i(e.nodeType)
              if (!y && Oa(e, t)) M(e, t, d, null, null, s)
              else {
                if (y) {
                  if ((1 === e.nodeType && e.hasAttribute(V) && (e.removeAttribute(V), (n = !0)), r(n) && x(e, t, d)))
                    return C(t, d, !0), e
                  ;(o = e), (e = new de(l.tagName(o).toLowerCase(), {}, [], void 0, o))
                }
                var f = e.elm,
                  m = l.parentNode(f)
                if ((c(t, d, f._leaveCb ? null : m, l.nextSibling(f)), i(t.parent)))
                  for (var h = t.parent, T = v(t); h; ) {
                    for (var b = 0; b < u.destroy.length; ++b) u.destroy[b](h)
                    if (((h.elm = t.elm), T)) {
                      for (var g = 0; g < u.create.length; ++g) u.create[g](xa, h)
                      var k = h.data.hook.insert
                      if (k.merged) for (var A = k.fns.slice(1), S = 0; S < A.length; S++) A[S]()
                    } else Ca(h)
                    h = h.parent
                  }
                i(m) ? _([e], 0, 0) : i(e.tag) && w(e)
              }
            }
            return C(t, d, p), t.elm
          }
          i(e) && w(e)
        }
      })({
        nodeOps: Aa,
        modules: [
          Wa,
          Xa,
          xi,
          Ei,
          Wi,
          G
            ? {
                create: fr,
                activate: fr,
                remove: function (e, t) {
                  !0 !== e.data.show ? dr(e, t) : t()
                },
              }
            : {},
        ].concat(Va),
      })
      X &&
        document.addEventListener('selectionchange', function () {
          var e = document.activeElement
          e && e.vmodel && kr(e, 'input')
        })
      var hr = {
        inserted: function (e, t, n, a) {
          'select' === n.tag
            ? (a.elm && !a.elm._vOptions
                ? We(n, 'postpatch', function () {
                    hr.componentUpdated(e, t, n)
                  })
                : vr(e, t, n.context),
              (e._vOptions = [].map.call(e.options, gr)))
            : ('textarea' === n.tag || _a(e.type)) &&
              ((e._vModifiers = t.modifiers),
              t.modifiers.lazy ||
                (e.addEventListener('compositionstart', wr),
                e.addEventListener('compositionend', _r),
                e.addEventListener('change', _r),
                X && (e.vmodel = !0)))
        },
        componentUpdated: function (e, t, n) {
          if ('select' === n.tag) {
            vr(e, t, n.context)
            var a = e._vOptions,
              i = (e._vOptions = [].map.call(e.options, gr))
            i.some(function (e, t) {
              return !U(e, a[t])
            }) &&
              (e.multiple
                ? t.value.some(function (e) {
                    return br(e, i)
                  })
                : t.value !== t.oldValue && br(t.value, i)) &&
              kr(e, 'change')
          }
        },
      }
      function vr(e, t, n) {
        Tr(e, t),
          (J || Y) &&
            setTimeout(function () {
              Tr(e, t)
            }, 0)
      }
      function Tr(e, t, n) {
        var a = t.value,
          i = e.multiple
        if (!i || Array.isArray(a)) {
          for (var r, s, o = 0, u = e.options.length; o < u; o++)
            if (((s = e.options[o]), i)) (r = $(a, gr(s)) > -1), s.selected !== r && (s.selected = r)
            else if (U(gr(s), a)) return void (e.selectedIndex !== o && (e.selectedIndex = o))
          i || (e.selectedIndex = -1)
        }
      }
      function br(e, t) {
        return t.every(function (t) {
          return !U(t, e)
        })
      }
      function gr(e) {
        return '_value' in e ? e._value : e.value
      }
      function wr(e) {
        e.target.composing = !0
      }
      function _r(e) {
        e.target.composing && ((e.target.composing = !1), kr(e.target, 'input'))
      }
      function kr(e, t) {
        var n = document.createEvent('HTMLEvents')
        n.initEvent(t, !0, !0), e.dispatchEvent(n)
      }
      function Ar(e) {
        return !e.componentInstance || (e.data && e.data.transition) ? e : Ar(e.componentInstance._vnode)
      }
      var Mr = {
          model: hr,
          show: {
            bind: function (e, t, n) {
              var a = t.value,
                i = (n = Ar(n)).data && n.data.transition,
                r = (e.__vOriginalDisplay = 'none' === e.style.display ? '' : e.style.display)
              a && i
                ? ((n.data.show = !0),
                  lr(n, function () {
                    e.style.display = r
                  }))
                : (e.style.display = a ? r : 'none')
            },
            update: function (e, t, n) {
              var a = t.value
              !a != !t.oldValue &&
                ((n = Ar(n)).data && n.data.transition
                  ? ((n.data.show = !0),
                    a
                      ? lr(n, function () {
                          e.style.display = e.__vOriginalDisplay
                        })
                      : dr(n, function () {
                          e.style.display = 'none'
                        }))
                  : (e.style.display = a ? e.__vOriginalDisplay : 'none'))
            },
            unbind: function (e, t, n, a, i) {
              i || (e.style.display = e.__vOriginalDisplay)
            },
          },
        },
        Cr = {
          name: String,
          appear: Boolean,
          css: Boolean,
          mode: String,
          type: String,
          enterClass: String,
          leaveClass: String,
          enterToClass: String,
          leaveToClass: String,
          enterActiveClass: String,
          leaveActiveClass: String,
          appearClass: String,
          appearActiveClass: String,
          appearToClass: String,
          duration: [Number, String, Object],
        }
      function Sr(e) {
        var t = e && e.componentOptions
        return t && t.Ctor.options.abstract ? Sr(Mt(t.children)) : e
      }
      function xr(e) {
        var t = {},
          n = e.$options
        for (var a in n.propsData) t[a] = e[a]
        var i = n._parentListeners
        for (var a in i) t[A(a)] = i[a]
        return t
      }
      function Rr(e, t) {
        if (/\d-keep-alive$/.test(t.tag)) return e('keep-alive', { props: t.componentOptions.propsData })
      }
      var Or = function (e) {
          return e.tag || ft(e)
        },
        Er = function (e) {
          return 'show' === e.name
        },
        Ir = {
          name: 'transition',
          props: Cr,
          abstract: !0,
          render: function (e) {
            var t = this,
              n = this.$slots.default
            if (n && (n = n.filter(Or)).length) {
              var a = this.mode,
                i = n[0]
              if (
                (function (e) {
                  for (; (e = e.parent); ) if (e.data.transition) return !0
                })(this.$vnode)
              )
                return i
              var r = Sr(i)
              if (!r) return i
              if (this._leaving) return Rr(e, i)
              var o = '__transition-'.concat(this._uid, '-')
              r.key =
                null == r.key
                  ? r.isComment
                    ? o + 'comment'
                    : o + r.tag
                  : s(r.key)
                  ? 0 === String(r.key).indexOf(o)
                    ? r.key
                    : o + r.key
                  : r.key
              var u = ((r.data || (r.data = {})).transition = xr(this)),
                p = this._vnode,
                l = Sr(p)
              if (
                (r.data.directives && r.data.directives.some(Er) && (r.data.show = !0),
                l &&
                  l.data &&
                  !(function (e, t) {
                    return t.key === e.key && t.tag === e.tag
                  })(r, l) &&
                  !ft(l) &&
                  (!l.componentInstance || !l.componentInstance._vnode.isComment))
              ) {
                var d = (l.data.transition = O({}, u))
                if ('out-in' === a)
                  return (
                    (this._leaving = !0),
                    We(d, 'afterLeave', function () {
                      ;(t._leaving = !1), t.$forceUpdate()
                    }),
                    Rr(e, i)
                  )
                if ('in-out' === a) {
                  if (ft(r)) return p
                  var c,
                    y = function () {
                      c()
                    }
                  We(u, 'afterEnter', y),
                    We(u, 'enterCancelled', y),
                    We(d, 'delayLeave', function (e) {
                      c = e
                    })
                }
              }
              return i
            }
          },
        },
        Pr = O({ tag: String, moveClass: String }, Cr)
      delete Pr.mode
      var Br = {
        props: Pr,
        beforeMount: function () {
          var e = this,
            t = this._update
          this._update = function (n, a) {
            var i = It(e)
            e.__patch__(e._vnode, e.kept, !1, !0), (e._vnode = e.kept), i(), t.call(e, n, a)
          }
        },
        render: function (e) {
          for (
            var t = this.tag || this.$vnode.data.tag || 'span',
              n = Object.create(null),
              a = (this.prevChildren = this.children),
              i = this.$slots.default || [],
              r = (this.children = []),
              s = xr(this),
              o = 0;
            o < i.length;
            o++
          )
            (l = i[o]).tag &&
              null != l.key &&
              0 !== String(l.key).indexOf('__vlist') &&
              (r.push(l), (n[l.key] = l), ((l.data || (l.data = {})).transition = s))
          if (a) {
            var u = [],
              p = []
            for (o = 0; o < a.length; o++) {
              var l
              ;((l = a[o]).data.transition = s),
                (l.data.pos = l.elm.getBoundingClientRect()),
                n[l.key] ? u.push(l) : p.push(l)
            }
            ;(this.kept = e(t, null, u)), (this.removed = p)
          }
          return e(t, null, r)
        },
        updated: function () {
          var e = this.prevChildren,
            t = this.moveClass || (this.name || 'v') + '-move'
          e.length &&
            this.hasMove(e[0].elm, t) &&
            (e.forEach(Ur),
            e.forEach($r),
            e.forEach(Dr),
            (this._reflow = document.body.offsetHeight),
            e.forEach(function (e) {
              if (e.data.moved) {
                var n = e.elm,
                  a = n.style
                ar(n, t),
                  (a.transform = a.WebkitTransform = a.transitionDuration = ''),
                  n.addEventListener(
                    Zi,
                    (n._moveCb = function e(a) {
                      ;(a && a.target !== n) ||
                        (a && !/transform$/.test(a.propertyName)) ||
                        (n.removeEventListener(Zi, e), (n._moveCb = null), ir(n, t))
                    })
                  )
              }
            }))
        },
        methods: {
          hasMove: function (e, t) {
            if (!Ki) return !1
            if (this._hasMove) return this._hasMove
            var n = e.cloneNode()
            e._transitionClasses &&
              e._transitionClasses.forEach(function (e) {
                zi(n, e)
              }),
              qi(n, t),
              (n.style.display = 'none'),
              this.$el.appendChild(n)
            var a = or(n)
            return this.$el.removeChild(n), (this._hasMove = a.hasTransform)
          },
        },
      }
      function Ur(e) {
        e.elm._moveCb && e.elm._moveCb(), e.elm._enterCb && e.elm._enterCb()
      }
      function $r(e) {
        e.data.newPos = e.elm.getBoundingClientRect()
      }
      function Dr(e) {
        var t = e.data.pos,
          n = e.data.newPos,
          a = t.left - n.left,
          i = t.top - n.top
        if (a || i) {
          e.data.moved = !0
          var r = e.elm.style
          ;(r.transform = r.WebkitTransform = 'translate('.concat(a, 'px,').concat(i, 'px)')),
            (r.transitionDuration = '0s')
        }
      }
      var Vr = { Transition: Ir, TransitionGroup: Br }
      ;(Jn.config.mustUseProp = ia),
        (Jn.config.isReservedTag = ba),
        (Jn.config.isReservedAttr = na),
        (Jn.config.getTagNamespace = ga),
        (Jn.config.isUnknownElement = function (e) {
          if (!G) return !0
          if (ba(e)) return !1
          if (((e = e.toLowerCase()), null != wa[e])) return wa[e]
          var t = document.createElement(e)
          return e.indexOf('-') > -1
            ? (wa[e] = t.constructor === window.HTMLUnknownElement || t.constructor === window.HTMLElement)
            : (wa[e] = /HTMLUnknownElement/.test(t.toString()))
        }),
        O(Jn.options.directives, Mr),
        O(Jn.options.components, Vr),
        (Jn.prototype.__patch__ = G ? mr : I),
        (Jn.prototype.$mount = function (e, t) {
          return (function (e, t, n) {
            var a
            ;(e.$el = t),
              e.$options.render || (e.$options.render = ce),
              $t(e, 'beforeMount'),
              (a = function () {
                e._update(e._render(), n)
              }),
              new mn(
                e,
                a,
                I,
                {
                  before: function () {
                    e._isMounted && !e._isDestroyed && $t(e, 'beforeUpdate')
                  },
                },
                !0
              ),
              (n = !1)
            var i = e._preWatchers
            if (i) for (var r = 0; r < i.length; r++) i[r].run()
            return null == e.$vnode && ((e._isMounted = !0), $t(e, 'mounted')), e
          })(this, (e = e && G ? ka(e) : void 0), t)
        }),
        G &&
          setTimeout(function () {
            F.devtools && re && re.emit('init', Jn)
          }, 0)
      var Nr,
        jr = /\{\{((?:.|\r?\n)+?)\}\}/g,
        Fr = /[-.*+?^${}()|[\]\/\\]/g,
        Wr = _(function (e) {
          var t = e[0].replace(Fr, '\\$&'),
            n = e[1].replace(Fr, '\\$&')
          return new RegExp(t + '((?:.|\\n)+?)' + n, 'g')
        }),
        Lr = {
          staticKeys: ['staticClass'],
          transformNode: function (e, t) {
            t.warn
            var n = pi(e, 'class')
            n && (e.staticClass = JSON.stringify(n.replace(/\s+/g, ' ').trim()))
            var a = ui(e, 'class', !1)
            a && (e.classBinding = a)
          },
          genData: function (e) {
            var t = ''
            return (
              e.staticClass && (t += 'staticClass:'.concat(e.staticClass, ',')),
              e.classBinding && (t += 'class:'.concat(e.classBinding, ',')),
              t
            )
          },
        },
        qr = {
          staticKeys: ['staticStyle'],
          transformNode: function (e, t) {
            t.warn
            var n = pi(e, 'style')
            n && (e.staticStyle = JSON.stringify(Ii(n)))
            var a = ui(e, 'style', !1)
            a && (e.styleBinding = a)
          },
          genData: function (e) {
            var t = ''
            return (
              e.staticStyle && (t += 'staticStyle:'.concat(e.staticStyle, ',')),
              e.styleBinding && (t += 'style:('.concat(e.styleBinding, '),')),
              t
            )
          },
        },
        zr = h('area,base,br,col,embed,frame,hr,img,input,isindex,keygen,link,meta,param,source,track,wbr'),
        Hr = h('colgroup,dd,dt,li,options,p,td,tfoot,th,thead,tr,source'),
        Gr = h(
          'address,article,aside,base,blockquote,body,caption,col,colgroup,dd,details,dialog,div,dl,dt,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,legend,li,menuitem,meta,optgroup,option,param,rp,rt,source,style,summary,tbody,td,tfoot,th,thead,title,tr,track'
        ),
        Kr = /^\s*([^\s"'<>\/=]+)(?:\s*(=)\s*(?:"([^"]*)"+|'([^']*)'+|([^\s"'=<>`]+)))?/,
        Jr = /^\s*((?:v-[\w-]+:|@|:|#)\[[^=]+?\][^\s"'<>\/=]*)(?:\s*(=)\s*(?:"([^"]*)"+|'([^']*)'+|([^\s"'=<>`]+)))?/,
        Xr = '[a-zA-Z_][\\-\\.0-9_a-zA-Z'.concat(W.source, ']*'),
        Yr = '((?:'.concat(Xr, '\\:)?').concat(Xr, ')'),
        Zr = new RegExp('^<'.concat(Yr)),
        Qr = /^\s*(\/?)>/,
        es = new RegExp('^<\\/'.concat(Yr, '[^>]*>')),
        ts = /^<!DOCTYPE [^>]+>/i,
        ns = /^<!\--/,
        as = /^<!\[/,
        is = h('script,style,textarea', !0),
        rs = {},
        ss = { '&lt;': '<', '&gt;': '>', '&quot;': '"', '&amp;': '&', '&#10;': '\n', '&#9;': '\t', '&#39;': "'" },
        os = /&(?:lt|gt|quot|amp|#39);/g,
        us = /&(?:lt|gt|quot|amp|#39|#10|#9);/g,
        ps = h('pre,textarea', !0),
        ls = function (e, t) {
          return e && ps(e) && '\n' === t[0]
        }
      function ds(e, t) {
        var n = t ? us : os
        return e.replace(n, function (e) {
          return ss[e]
        })
      }
      var cs,
        ys,
        fs,
        ms,
        hs,
        vs,
        Ts,
        bs,
        gs = /^@|^v-on:/,
        ws = /^v-|^@|^:|^#/,
        _s = /([\s\S]*?)\s+(?:in|of)\s+([\s\S]*)/,
        ks = /,([^,\}\]]*)(?:,([^,\}\]]*))?$/,
        As = /^\(|\)$/g,
        Ms = /^\[.*\]$/,
        Cs = /:(.*)$/,
        Ss = /^:|^\.|^v-bind:/,
        xs = /\.[^.\]]+(?=[^\]]*$)/g,
        Rs = /^v-slot(:|$)|^#/,
        Os = /[\r\n]/,
        Es = /[ \f\t\r\n]+/g,
        Is = _(function (e) {
          return ((Nr = Nr || document.createElement('div')).innerHTML = e), Nr.textContent
        }),
        Ps = '_empty_'
      function Bs(e, t, n) {
        return { type: 1, tag: e, attrsList: t, attrsMap: Fs(t), rawAttrsMap: {}, parent: n, children: [] }
      }
      function Us(e, t) {
        ;(cs = t.warn || ei), (vs = t.isPreTag || P), (Ts = t.mustUseProp || P), (bs = t.getTagNamespace || P)
        t.isReservedTag
        ;(fs = ti(t.modules, 'transformNode')),
          (ms = ti(t.modules, 'preTransformNode')),
          (hs = ti(t.modules, 'postTransformNode')),
          (ys = t.delimiters)
        var n,
          a,
          i = [],
          r = !1 !== t.preserveWhitespace,
          s = t.whitespace,
          o = !1,
          u = !1
        function p(e) {
          if (
            (l(e),
            o || e.processed || (e = $s(e, t)),
            i.length || e === n || (n.if && (e.elseif || e.else) && Vs(n, { exp: e.elseif, block: e })),
            a && !e.forbidden)
          )
            if (e.elseif || e.else)
              (s = e),
                (p = (function (e) {
                  for (var t = e.length; t--; ) {
                    if (1 === e[t].type) return e[t]
                    e.pop()
                  }
                })(a.children)),
                p && p.if && Vs(p, { exp: s.elseif, block: s })
            else {
              if (e.slotScope) {
                var r = e.slotTarget || '"default"'
                ;(a.scopedSlots || (a.scopedSlots = {}))[r] = e
              }
              a.children.push(e), (e.parent = a)
            }
          var s, p
          ;(e.children = e.children.filter(function (e) {
            return !e.slotScope
          })),
            l(e),
            e.pre && (o = !1),
            vs(e.tag) && (u = !1)
          for (var d = 0; d < hs.length; d++) hs[d](e, t)
        }
        function l(e) {
          if (!u)
            for (var t = void 0; (t = e.children[e.children.length - 1]) && 3 === t.type && ' ' === t.text; )
              e.children.pop()
        }
        return (
          (function (e, t) {
            for (
              var n,
                a,
                i = [],
                r = t.expectHTML,
                s = t.isUnaryTag || P,
                o = t.canBeLeftOpenTag || P,
                u = 0,
                p = function () {
                  if (((n = e), a && is(a))) {
                    var p = 0,
                      c = a.toLowerCase(),
                      y = rs[c] || (rs[c] = new RegExp('([\\s\\S]*?)(</' + c + '[^>]*>)', 'i'))
                    ;(_ = e.replace(y, function (e, n, a) {
                      return (
                        (p = a.length),
                        is(c) ||
                          'noscript' === c ||
                          (n = n.replace(/<!\--([\s\S]*?)-->/g, '$1').replace(/<!\[CDATA\[([\s\S]*?)]]>/g, '$1')),
                        ls(c, n) && (n = n.slice(1)),
                        t.chars && t.chars(n),
                        ''
                      )
                    })),
                      (u += e.length - _.length),
                      (e = _),
                      d(c, u - p, u)
                  } else {
                    var f = e.indexOf('<')
                    if (0 === f) {
                      if (ns.test(e)) {
                        var m = e.indexOf('--\x3e')
                        if (m >= 0)
                          return (
                            t.shouldKeepComment && t.comment && t.comment(e.substring(4, m), u, u + m + 3),
                            l(m + 3),
                            'continue'
                          )
                      }
                      if (as.test(e)) {
                        var h = e.indexOf(']>')
                        if (h >= 0) return l(h + 2), 'continue'
                      }
                      var v = e.match(ts)
                      if (v) return l(v[0].length), 'continue'
                      var T = e.match(es)
                      if (T) {
                        var b = u
                        return l(T[0].length), d(T[1], b, u), 'continue'
                      }
                      var g = (function () {
                        var t = e.match(Zr)
                        if (t) {
                          var n = { tagName: t[1], attrs: [], start: u }
                          l(t[0].length)
                          for (var a = void 0, i = void 0; !(a = e.match(Qr)) && (i = e.match(Jr) || e.match(Kr)); )
                            (i.start = u), l(i[0].length), (i.end = u), n.attrs.push(i)
                          if (a) return (n.unarySlash = a[1]), l(a[0].length), (n.end = u), n
                        }
                      })()
                      if (g)
                        return (
                          (function (e) {
                            var n = e.tagName,
                              u = e.unarySlash
                            r && ('p' === a && Gr(n) && d(a), o(n) && a === n && d(n))
                            for (var p = s(n) || !!u, l = e.attrs.length, c = new Array(l), y = 0; y < l; y++) {
                              var f = e.attrs[y],
                                m = f[3] || f[4] || f[5] || '',
                                h =
                                  'a' === n && 'href' === f[1] ? t.shouldDecodeNewlinesForHref : t.shouldDecodeNewlines
                              c[y] = { name: f[1], value: ds(m, h) }
                            }
                            p ||
                              (i.push({ tag: n, lowerCasedTag: n.toLowerCase(), attrs: c, start: e.start, end: e.end }),
                              (a = n)),
                              t.start && t.start(n, c, p, e.start, e.end)
                          })(g),
                          ls(g.tagName, e) && l(1),
                          'continue'
                        )
                    }
                    var w = void 0,
                      _ = void 0,
                      k = void 0
                    if (f >= 0) {
                      for (
                        _ = e.slice(f);
                        !(es.test(_) || Zr.test(_) || ns.test(_) || as.test(_) || (k = _.indexOf('<', 1)) < 0);

                      )
                        (f += k), (_ = e.slice(f))
                      w = e.substring(0, f)
                    }
                    f < 0 && (w = e), w && l(w.length), t.chars && w && t.chars(w, u - w.length, u)
                  }
                  if (e === n) return t.chars && t.chars(e), 'break'
                };
              e && 'break' !== p();

            );
            function l(t) {
              ;(u += t), (e = e.substring(t))
            }
            function d(e, n, r) {
              var s, o
              if ((null == n && (n = u), null == r && (r = u), e))
                for (o = e.toLowerCase(), s = i.length - 1; s >= 0 && i[s].lowerCasedTag !== o; s--);
              else s = 0
              if (s >= 0) {
                for (var p = i.length - 1; p >= s; p--) t.end && t.end(i[p].tag, n, r)
                ;(i.length = s), (a = s && i[s - 1].tag)
              } else
                'br' === o
                  ? t.start && t.start(e, [], !0, n, r)
                  : 'p' === o && (t.start && t.start(e, [], !1, n, r), t.end && t.end(e, n, r))
            }
            d()
          })(e, {
            warn: cs,
            expectHTML: t.expectHTML,
            isUnaryTag: t.isUnaryTag,
            canBeLeftOpenTag: t.canBeLeftOpenTag,
            shouldDecodeNewlines: t.shouldDecodeNewlines,
            shouldDecodeNewlinesForHref: t.shouldDecodeNewlinesForHref,
            shouldKeepComment: t.comments,
            outputSourceRange: t.outputSourceRange,
            start: function (e, r, s, l, d) {
              var c = (a && a.ns) || bs(e)
              J &&
                'svg' === c &&
                (r = (function (e) {
                  for (var t = [], n = 0; n < e.length; n++) {
                    var a = e[n]
                    Ws.test(a.name) || ((a.name = a.name.replace(Ls, '')), t.push(a))
                  }
                  return t
                })(r))
              var y,
                f = Bs(e, r, a)
              c && (f.ns = c),
                ('style' !== (y = f).tag &&
                  ('script' !== y.tag || (y.attrsMap.type && 'text/javascript' !== y.attrsMap.type))) ||
                  ie() ||
                  (f.forbidden = !0)
              for (var m = 0; m < ms.length; m++) f = ms[m](f, t) || f
              o ||
                ((function (e) {
                  null != pi(e, 'v-pre') && (e.pre = !0)
                })(f),
                f.pre && (o = !0)),
                vs(f.tag) && (u = !0),
                o
                  ? (function (e) {
                      var t = e.attrsList,
                        n = t.length
                      if (n)
                        for (var a = (e.attrs = new Array(n)), i = 0; i < n; i++)
                          (a[i] = { name: t[i].name, value: JSON.stringify(t[i].value) }),
                            null != t[i].start && ((a[i].start = t[i].start), (a[i].end = t[i].end))
                      else e.pre || (e.plain = !0)
                    })(f)
                  : f.processed ||
                    (Ds(f),
                    (function (e) {
                      var t = pi(e, 'v-if')
                      if (t) (e.if = t), Vs(e, { exp: t, block: e })
                      else {
                        null != pi(e, 'v-else') && (e.else = !0)
                        var n = pi(e, 'v-else-if')
                        n && (e.elseif = n)
                      }
                    })(f),
                    (function (e) {
                      null != pi(e, 'v-once') && (e.once = !0)
                    })(f)),
                n || (n = f),
                s ? p(f) : ((a = f), i.push(f))
            },
            end: function (e, t, n) {
              var r = i[i.length - 1]
              ;(i.length -= 1), (a = i[i.length - 1]), p(r)
            },
            chars: function (e, t, n) {
              if (a && (!J || 'textarea' !== a.tag || a.attrsMap.placeholder !== e)) {
                var i,
                  p = a.children
                if (
                  (e =
                    u || e.trim()
                      ? 'script' === (i = a).tag || 'style' === i.tag
                        ? e
                        : Is(e)
                      : p.length
                      ? s
                        ? 'condense' === s && Os.test(e)
                          ? ''
                          : ' '
                        : r
                        ? ' '
                        : ''
                      : '')
                ) {
                  u || 'condense' !== s || (e = e.replace(Es, ' '))
                  var l = void 0,
                    d = void 0
                  !o &&
                  ' ' !== e &&
                  (l = (function (e, t) {
                    var n = t ? Wr(t) : jr
                    if (n.test(e)) {
                      for (var a, i, r, s = [], o = [], u = (n.lastIndex = 0); (a = n.exec(e)); ) {
                        ;(i = a.index) > u && (o.push((r = e.slice(u, i))), s.push(JSON.stringify(r)))
                        var p = Za(a[1].trim())
                        s.push('_s('.concat(p, ')')), o.push({ '@binding': p }), (u = i + a[0].length)
                      }
                      return (
                        u < e.length && (o.push((r = e.slice(u))), s.push(JSON.stringify(r))),
                        { expression: s.join('+'), tokens: o }
                      )
                    }
                  })(e, ys))
                    ? (d = { type: 2, expression: l.expression, tokens: l.tokens, text: e })
                    : (' ' === e && p.length && ' ' === p[p.length - 1].text) || (d = { type: 3, text: e }),
                    d && p.push(d)
                }
              }
            },
            comment: function (e, t, n) {
              if (a) {
                var i = { type: 3, text: e, isComment: !0 }
                a.children.push(i)
              }
            },
          }),
          n
        )
      }
      function $s(e, t) {
        var n
        !(function (e) {
          var t = ui(e, 'key')
          t && (e.key = t)
        })(e),
          (e.plain = !e.key && !e.scopedSlots && !e.attrsList.length),
          (function (e) {
            var t = ui(e, 'ref')
            t &&
              ((e.ref = t),
              (e.refInFor = (function (e) {
                for (var t = e; t; ) {
                  if (void 0 !== t.for) return !0
                  t = t.parent
                }
                return !1
              })(e)))
          })(e),
          (function (e) {
            var t
            'template' === e.tag
              ? ((t = pi(e, 'scope')), (e.slotScope = t || pi(e, 'slot-scope')))
              : (t = pi(e, 'slot-scope')) && (e.slotScope = t)
            var n,
              a = ui(e, 'slot')
            if (
              (a &&
                ((e.slotTarget = '""' === a ? '"default"' : a),
                (e.slotTargetDynamic = !(!e.attrsMap[':slot'] && !e.attrsMap['v-bind:slot'])),
                'template' === e.tag ||
                  e.slotScope ||
                  ai(
                    e,
                    'slot',
                    a,
                    (function (e, t) {
                      return e.rawAttrsMap[':' + t] || e.rawAttrsMap['v-bind:' + t] || e.rawAttrsMap[t]
                    })(e, 'slot')
                  )),
              'template' === e.tag)
            ) {
              if ((n = li(e, Rs))) {
                var i = Ns(n),
                  r = i.name,
                  s = i.dynamic
                ;(e.slotTarget = r), (e.slotTargetDynamic = s), (e.slotScope = n.value || Ps)
              }
            } else if ((n = li(e, Rs))) {
              var o = e.scopedSlots || (e.scopedSlots = {}),
                u = Ns(n),
                p = u.name,
                l = ((s = u.dynamic), (o[p] = Bs('template', [], e)))
              ;(l.slotTarget = p),
                (l.slotTargetDynamic = s),
                (l.children = e.children.filter(function (e) {
                  if (!e.slotScope) return (e.parent = l), !0
                })),
                (l.slotScope = n.value || Ps),
                (e.children = []),
                (e.plain = !1)
            }
          })(e),
          'slot' === (n = e).tag && (n.slotName = ui(n, 'name')),
          (function (e) {
            var t
            ;(t = ui(e, 'is')) && (e.component = t), null != pi(e, 'inline-template') && (e.inlineTemplate = !0)
          })(e)
        for (var a = 0; a < fs.length; a++) e = fs[a](e, t) || e
        return (
          (function (e) {
            var t,
              n,
              a,
              i,
              r,
              s,
              o,
              u,
              p = e.attrsList
            for (t = 0, n = p.length; t < n; t++)
              if (((a = i = p[t].name), (r = p[t].value), ws.test(a)))
                if (((e.hasBindings = !0), (s = js(a.replace(ws, ''))) && (a = a.replace(xs, '')), Ss.test(a)))
                  (a = a.replace(Ss, '')),
                    (r = Za(r)),
                    (u = Ms.test(a)) && (a = a.slice(1, -1)),
                    s &&
                      (s.prop && !u && 'innerHtml' === (a = A(a)) && (a = 'innerHTML'),
                      s.camel && !u && (a = A(a)),
                      s.sync &&
                        ((o = yi(r, '$event')),
                        u
                          ? oi(e, '"update:"+('.concat(a, ')'), o, null, !1, 0, p[t], !0)
                          : (oi(e, 'update:'.concat(A(a)), o, null, !1, 0, p[t]),
                            S(a) !== A(a) && oi(e, 'update:'.concat(S(a)), o, null, !1, 0, p[t])))),
                    (s && s.prop) || (!e.component && Ts(e.tag, e.attrsMap.type, a))
                      ? ni(e, a, r, p[t], u)
                      : ai(e, a, r, p[t], u)
                else if (gs.test(a))
                  (a = a.replace(gs, '')), (u = Ms.test(a)) && (a = a.slice(1, -1)), oi(e, a, r, s, !1, 0, p[t], u)
                else {
                  var l = (a = a.replace(ws, '')).match(Cs),
                    d = l && l[1]
                  ;(u = !1),
                    d && ((a = a.slice(0, -(d.length + 1))), Ms.test(d) && ((d = d.slice(1, -1)), (u = !0))),
                    ri(e, a, i, r, d, u, s, p[t])
                }
              else
                ai(e, a, JSON.stringify(r), p[t]),
                  !e.component && 'muted' === a && Ts(e.tag, e.attrsMap.type, a) && ni(e, a, 'true', p[t])
          })(e),
          e
        )
      }
      function Ds(e) {
        var t
        if ((t = pi(e, 'v-for'))) {
          var n = (function (e) {
            var t = e.match(_s)
            if (t) {
              var n = {}
              n.for = t[2].trim()
              var a = t[1].trim().replace(As, ''),
                i = a.match(ks)
              return (
                i
                  ? ((n.alias = a.replace(ks, '').trim()),
                    (n.iterator1 = i[1].trim()),
                    i[2] && (n.iterator2 = i[2].trim()))
                  : (n.alias = a),
                n
              )
            }
          })(t)
          n && O(e, n)
        }
      }
      function Vs(e, t) {
        e.ifConditions || (e.ifConditions = []), e.ifConditions.push(t)
      }
      function Ns(e) {
        var t = e.name.replace(Rs, '')
        return (
          t || ('#' !== e.name[0] && (t = 'default')),
          Ms.test(t) ? { name: t.slice(1, -1), dynamic: !0 } : { name: '"'.concat(t, '"'), dynamic: !1 }
        )
      }
      function js(e) {
        var t = e.match(xs)
        if (t) {
          var n = {}
          return (
            t.forEach(function (e) {
              n[e.slice(1)] = !0
            }),
            n
          )
        }
      }
      function Fs(e) {
        for (var t = {}, n = 0, a = e.length; n < a; n++) t[e[n].name] = e[n].value
        return t
      }
      var Ws = /^xmlns:NS\d+/,
        Ls = /^NS\d+:/
      function qs(e) {
        return Bs(e.tag, e.attrsList.slice(), e.parent)
      }
      var zs,
        Hs,
        Gs = [
          Lr,
          qr,
          {
            preTransformNode: function (e, t) {
              if ('input' === e.tag) {
                var n = e.attrsMap
                if (!n['v-model']) return
                var a = void 0
                if (
                  ((n[':type'] || n['v-bind:type']) && (a = ui(e, 'type')),
                  n.type || a || !n['v-bind'] || (a = '('.concat(n['v-bind'], ').type')),
                  a)
                ) {
                  var i = pi(e, 'v-if', !0),
                    r = i ? '&&('.concat(i, ')') : '',
                    s = null != pi(e, 'v-else', !0),
                    o = pi(e, 'v-else-if', !0),
                    u = qs(e)
                  Ds(u),
                    ii(u, 'type', 'checkbox'),
                    $s(u, t),
                    (u.processed = !0),
                    (u.if = '('.concat(a, ")==='checkbox'") + r),
                    Vs(u, { exp: u.if, block: u })
                  var p = qs(e)
                  pi(p, 'v-for', !0),
                    ii(p, 'type', 'radio'),
                    $s(p, t),
                    Vs(u, { exp: '('.concat(a, ")==='radio'") + r, block: p })
                  var l = qs(e)
                  return (
                    pi(l, 'v-for', !0),
                    ii(l, ':type', a),
                    $s(l, t),
                    Vs(u, { exp: i, block: l }),
                    s ? (u.else = !0) : o && (u.elseif = o),
                    u
                  )
                }
              }
            },
          },
        ],
        Ks = {
          expectHTML: !0,
          modules: Gs,
          directives: {
            model: function (e, t, n) {
              var a = t.value,
                i = t.modifiers,
                r = e.tag,
                s = e.attrsMap.type
              if (e.component) return ci(e, a, i), !1
              if ('select' === r)
                !(function (e, t, n) {
                  var a = n && n.number,
                    i =
                      'Array.prototype.filter.call($event.target.options,function(o){return o.selected}).map(function(o){var val = "_value" in o ? o._value : o.value;' +
                      'return '.concat(a ? '_n(val)' : 'val', '})'),
                    r = 'var $$selectedVal = '.concat(i, ';')
                  oi(
                    e,
                    'change',
                    (r = ''.concat(r, ' ').concat(yi(t, '$event.target.multiple ? $$selectedVal : $$selectedVal[0]'))),
                    null,
                    !0
                  )
                })(e, a, i)
              else if ('input' === r && 'checkbox' === s)
                !(function (e, t, n) {
                  var a = n && n.number,
                    i = ui(e, 'value') || 'null',
                    r = ui(e, 'true-value') || 'true',
                    s = ui(e, 'false-value') || 'false'
                  ni(
                    e,
                    'checked',
                    'Array.isArray('.concat(t, ')') +
                      '?_i('.concat(t, ',').concat(i, ')>-1') +
                      ('true' === r ? ':('.concat(t, ')') : ':_q('.concat(t, ',').concat(r, ')'))
                  ),
                    oi(
                      e,
                      'change',
                      'var $$a='.concat(t, ',') +
                        '$$el=$event.target,' +
                        '$$c=$$el.checked?('.concat(r, '):(').concat(s, ');') +
                        'if(Array.isArray($$a)){' +
                        'var $$v='.concat(a ? '_n(' + i + ')' : i, ',') +
                        '$$i=_i($$a,$$v);' +
                        'if($$el.checked){$$i<0&&('.concat(yi(t, '$$a.concat([$$v])'), ')}') +
                        'else{$$i>-1&&('.concat(yi(t, '$$a.slice(0,$$i).concat($$a.slice($$i+1))'), ')}') +
                        '}else{'.concat(yi(t, '$$c'), '}'),
                      null,
                      !0
                    )
                })(e, a, i)
              else if ('input' === r && 'radio' === s)
                !(function (e, t, n) {
                  var a = n && n.number,
                    i = ui(e, 'value') || 'null'
                  ;(i = a ? '_n('.concat(i, ')') : i),
                    ni(e, 'checked', '_q('.concat(t, ',').concat(i, ')')),
                    oi(e, 'change', yi(t, i), null, !0)
                })(e, a, i)
              else if ('input' === r || 'textarea' === r)
                !(function (e, t, n) {
                  var a = e.attrsMap.type,
                    i = n || {},
                    r = i.lazy,
                    s = i.number,
                    o = i.trim,
                    u = !r && 'range' !== a,
                    p = r ? 'change' : 'range' === a ? gi : 'input',
                    l = '$event.target.value'
                  o && (l = '$event.target.value.trim()'), s && (l = '_n('.concat(l, ')'))
                  var d = yi(t, l)
                  u && (d = 'if($event.target.composing)return;'.concat(d)),
                    ni(e, 'value', '('.concat(t, ')')),
                    oi(e, p, d, null, !0),
                    (o || s) && oi(e, 'blur', '$forceUpdate()')
                })(e, a, i)
              else if (!F.isReservedTag(r)) return ci(e, a, i), !1
              return !0
            },
            text: function (e, t) {
              t.value && ni(e, 'textContent', '_s('.concat(t.value, ')'), t)
            },
            html: function (e, t) {
              t.value && ni(e, 'innerHTML', '_s('.concat(t.value, ')'), t)
            },
          },
          isPreTag: function (e) {
            return 'pre' === e
          },
          isUnaryTag: zr,
          mustUseProp: ia,
          canBeLeftOpenTag: Hr,
          isReservedTag: ba,
          getTagNamespace: ga,
          staticKeys: (function (e) {
            return e
              .reduce(function (e, t) {
                return e.concat(t.staticKeys || [])
              }, [])
              .join(',')
          })(Gs),
        },
        Js = _(function (e) {
          return h('type,tag,attrsList,attrsMap,plain,parent,children,attrs,start,end,rawAttrsMap' + (e ? ',' + e : ''))
        })
      function Xs(e, t) {
        e && ((zs = Js(t.staticKeys || '')), (Hs = t.isReservedTag || P), Ys(e), Zs(e, !1))
      }
      function Ys(e) {
        if (
          ((e.static = (function (e) {
            return (
              2 !== e.type &&
              (3 === e.type ||
                !(
                  !e.pre &&
                  (e.hasBindings ||
                    e.if ||
                    e.for ||
                    v(e.tag) ||
                    !Hs(e.tag) ||
                    (function (e) {
                      for (; e.parent; ) {
                        if ('template' !== (e = e.parent).tag) return !1
                        if (e.for) return !0
                      }
                      return !1
                    })(e) ||
                    !Object.keys(e).every(zs))
                ))
            )
          })(e)),
          1 === e.type)
        ) {
          if (!Hs(e.tag) && 'slot' !== e.tag && null == e.attrsMap['inline-template']) return
          for (var t = 0, n = e.children.length; t < n; t++) {
            var a = e.children[t]
            Ys(a), a.static || (e.static = !1)
          }
          if (e.ifConditions)
            for (t = 1, n = e.ifConditions.length; t < n; t++) {
              var i = e.ifConditions[t].block
              Ys(i), i.static || (e.static = !1)
            }
        }
      }
      function Zs(e, t) {
        if (1 === e.type) {
          if (
            ((e.static || e.once) && (e.staticInFor = t),
            e.static && e.children.length && (1 !== e.children.length || 3 !== e.children[0].type))
          )
            return void (e.staticRoot = !0)
          if (((e.staticRoot = !1), e.children))
            for (var n = 0, a = e.children.length; n < a; n++) Zs(e.children[n], t || !!e.for)
          if (e.ifConditions) for (n = 1, a = e.ifConditions.length; n < a; n++) Zs(e.ifConditions[n].block, t)
        }
      }
      var Qs = /^([\w$_]+|\([^)]*?\))\s*=>|^function(?:\s+[\w$]+)?\s*\(/,
        eo = /\([^)]*?\);*$/,
        to = /^[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*|\['[^']*?']|\["[^"]*?"]|\[\d+]|\[[A-Za-z_$][\w$]*])*$/,
        no = { esc: 27, tab: 9, enter: 13, space: 32, up: 38, left: 37, right: 39, down: 40, delete: [8, 46] },
        ao = {
          esc: ['Esc', 'Escape'],
          tab: 'Tab',
          enter: 'Enter',
          space: [' ', 'Spacebar'],
          up: ['Up', 'ArrowUp'],
          left: ['Left', 'ArrowLeft'],
          right: ['Right', 'ArrowRight'],
          down: ['Down', 'ArrowDown'],
          delete: ['Backspace', 'Delete', 'Del'],
        },
        io = function (e) {
          return 'if('.concat(e, ')return null;')
        },
        ro = {
          stop: '$event.stopPropagation();',
          prevent: '$event.preventDefault();',
          self: io('$event.target !== $event.currentTarget'),
          ctrl: io('!$event.ctrlKey'),
          shift: io('!$event.shiftKey'),
          alt: io('!$event.altKey'),
          meta: io('!$event.metaKey'),
          left: io("'button' in $event && $event.button !== 0"),
          middle: io("'button' in $event && $event.button !== 1"),
          right: io("'button' in $event && $event.button !== 2"),
        }
      function so(e, t) {
        var n = t ? 'nativeOn:' : 'on:',
          a = '',
          i = ''
        for (var r in e) {
          var s = oo(e[r])
          e[r] && e[r].dynamic ? (i += ''.concat(r, ',').concat(s, ',')) : (a += '"'.concat(r, '":').concat(s, ','))
        }
        return (a = '{'.concat(a.slice(0, -1), '}')), i ? n + '_d('.concat(a, ',[').concat(i.slice(0, -1), '])') : n + a
      }
      function oo(e) {
        if (!e) return 'function(){}'
        if (Array.isArray(e))
          return '['.concat(
            e
              .map(function (e) {
                return oo(e)
              })
              .join(','),
            ']'
          )
        var t = to.test(e.value),
          n = Qs.test(e.value),
          a = to.test(e.value.replace(eo, ''))
        if (e.modifiers) {
          var i = '',
            r = '',
            s = [],
            o = function (t) {
              if (ro[t]) (r += ro[t]), no[t] && s.push(t)
              else if ('exact' === t) {
                var n = e.modifiers
                r += io(
                  ['ctrl', 'shift', 'alt', 'meta']
                    .filter(function (e) {
                      return !n[e]
                    })
                    .map(function (e) {
                      return '$event.'.concat(e, 'Key')
                    })
                    .join('||')
                )
              } else s.push(t)
            }
          for (var u in e.modifiers) o(u)
          s.length &&
            (i += (function (e) {
              return "if(!$event.type.indexOf('key')&&" + ''.concat(e.map(uo).join('&&'), ')return null;')
            })(s)),
            r && (i += r)
          var p = t
            ? 'return '.concat(e.value, '.apply(null, arguments)')
            : n
            ? 'return ('.concat(e.value, ').apply(null, arguments)')
            : a
            ? 'return '.concat(e.value)
            : e.value
          return 'function($event){'.concat(i).concat(p, '}')
        }
        return t || n ? e.value : 'function($event){'.concat(a ? 'return '.concat(e.value) : e.value, '}')
      }
      function uo(e) {
        var t = parseInt(e, 10)
        if (t) return '$event.keyCode!=='.concat(t)
        var n = no[e],
          a = ao[e]
        return (
          '_k($event.keyCode,' +
          ''.concat(JSON.stringify(e), ',') +
          ''.concat(JSON.stringify(n), ',') +
          '$event.key,' +
          ''.concat(JSON.stringify(a)) +
          ')'
        )
      }
      var po = {
          on: function (e, t) {
            e.wrapListeners = function (e) {
              return '_g('.concat(e, ',').concat(t.value, ')')
            }
          },
          bind: function (e, t) {
            e.wrapData = function (n) {
              return '_b('
                .concat(n, ",'")
                .concat(e.tag, "',")
                .concat(t.value, ',')
                .concat(t.modifiers && t.modifiers.prop ? 'true' : 'false')
                .concat(t.modifiers && t.modifiers.sync ? ',true' : '', ')')
            }
          },
          cloak: I,
        },
        lo = function (e) {
          ;(this.options = e),
            (this.warn = e.warn || ei),
            (this.transforms = ti(e.modules, 'transformCode')),
            (this.dataGenFns = ti(e.modules, 'genData')),
            (this.directives = O(O({}, po), e.directives))
          var t = e.isReservedTag || P
          ;(this.maybeComponent = function (e) {
            return !!e.component || !t(e.tag)
          }),
            (this.onceId = 0),
            (this.staticRenderFns = []),
            (this.pre = !1)
        }
      function co(e, t) {
        var n = new lo(t),
          a = e ? ('script' === e.tag ? 'null' : yo(e, n)) : '_c("div")'
        return { render: 'with(this){return '.concat(a, '}'), staticRenderFns: n.staticRenderFns }
      }
      function yo(e, t) {
        if ((e.parent && (e.pre = e.pre || e.parent.pre), e.staticRoot && !e.staticProcessed)) return fo(e, t)
        if (e.once && !e.onceProcessed) return mo(e, t)
        if (e.for && !e.forProcessed) return To(e, t)
        if (e.if && !e.ifProcessed) return ho(e, t)
        if ('template' !== e.tag || e.slotTarget || t.pre) {
          if ('slot' === e.tag)
            return (function (e, t) {
              var n = e.slotName || '"default"',
                a = _o(e, t),
                i = '_t('.concat(n).concat(a ? ',function(){return '.concat(a, '}') : ''),
                r =
                  e.attrs || e.dynamicAttrs
                    ? Mo(
                        (e.attrs || []).concat(e.dynamicAttrs || []).map(function (e) {
                          return { name: A(e.name), value: e.value, dynamic: e.dynamic }
                        })
                      )
                    : null,
                s = e.attrsMap['v-bind']
              return (
                (!r && !s) || a || (i += ',null'),
                r && (i += ','.concat(r)),
                s && (i += ''.concat(r ? '' : ',null', ',').concat(s)),
                i + ')'
              )
            })(e, t)
          var n = void 0
          if (e.component)
            n = (function (e, t, n) {
              var a = t.inlineTemplate ? null : _o(t, n, !0)
              return '_c('
                .concat(e, ',')
                .concat(bo(t, n))
                .concat(a ? ','.concat(a) : '', ')')
            })(e.component, e, t)
          else {
            var a = void 0,
              i = t.maybeComponent(e)
            ;(!e.plain || (e.pre && i)) && (a = bo(e, t))
            var r = void 0,
              s = t.options.bindings
            i &&
              s &&
              !1 !== s.__isScriptSetup &&
              (r = (function (e, t) {
                var n = A(t),
                  a = M(n),
                  i = function (i) {
                    return e[t] === i ? t : e[n] === i ? n : e[a] === i ? a : void 0
                  },
                  r = i('setup-const') || i('setup-reactive-const')
                if (r) return r
                var s = i('setup-let') || i('setup-ref') || i('setup-maybe-ref')
                return s || void 0
              })(s, e.tag)),
              r || (r = "'".concat(e.tag, "'"))
            var o = e.inlineTemplate ? null : _o(e, t, !0)
            n = '_c('
              .concat(r)
              .concat(a ? ','.concat(a) : '')
              .concat(o ? ','.concat(o) : '', ')')
          }
          for (var u = 0; u < t.transforms.length; u++) n = t.transforms[u](e, n)
          return n
        }
        return _o(e, t) || 'void 0'
      }
      function fo(e, t) {
        e.staticProcessed = !0
        var n = t.pre
        return (
          e.pre && (t.pre = e.pre),
          t.staticRenderFns.push('with(this){return '.concat(yo(e, t), '}')),
          (t.pre = n),
          '_m('.concat(t.staticRenderFns.length - 1).concat(e.staticInFor ? ',true' : '', ')')
        )
      }
      function mo(e, t) {
        if (((e.onceProcessed = !0), e.if && !e.ifProcessed)) return ho(e, t)
        if (e.staticInFor) {
          for (var n = '', a = e.parent; a; ) {
            if (a.for) {
              n = a.key
              break
            }
            a = a.parent
          }
          return n ? '_o('.concat(yo(e, t), ',').concat(t.onceId++, ',').concat(n, ')') : yo(e, t)
        }
        return fo(e, t)
      }
      function ho(e, t, n, a) {
        return (e.ifProcessed = !0), vo(e.ifConditions.slice(), t, n, a)
      }
      function vo(e, t, n, a) {
        if (!e.length) return a || '_e()'
        var i = e.shift()
        return i.exp ? '('.concat(i.exp, ')?').concat(r(i.block), ':').concat(vo(e, t, n, a)) : ''.concat(r(i.block))
        function r(e) {
          return n ? n(e, t) : e.once ? mo(e, t) : yo(e, t)
        }
      }
      function To(e, t, n, a) {
        var i = e.for,
          r = e.alias,
          s = e.iterator1 ? ','.concat(e.iterator1) : '',
          o = e.iterator2 ? ','.concat(e.iterator2) : ''
        return (
          (e.forProcessed = !0),
          ''.concat(a || '_l', '((').concat(i, '),') +
            'function('.concat(r).concat(s).concat(o, '){') +
            'return '.concat((n || yo)(e, t)) +
            '})'
        )
      }
      function bo(e, t) {
        var n = '{',
          a = (function (e, t) {
            var n = e.directives
            if (n) {
              var a,
                i,
                r,
                s,
                o = 'directives:[',
                u = !1
              for (a = 0, i = n.length; a < i; a++) {
                ;(r = n[a]), (s = !0)
                var p = t.directives[r.name]
                p && (s = !!p(e, r, t.warn)),
                  s &&
                    ((u = !0),
                    (o += '{name:"'
                      .concat(r.name, '",rawName:"')
                      .concat(r.rawName, '"')
                      .concat(
                        r.value ? ',value:('.concat(r.value, '),expression:').concat(JSON.stringify(r.value)) : ''
                      )
                      .concat(r.arg ? ',arg:'.concat(r.isDynamicArg ? r.arg : '"'.concat(r.arg, '"')) : '')
                      .concat(r.modifiers ? ',modifiers:'.concat(JSON.stringify(r.modifiers)) : '', '},')))
              }
              return u ? o.slice(0, -1) + ']' : void 0
            }
          })(e, t)
        a && (n += a + ','),
          e.key && (n += 'key:'.concat(e.key, ',')),
          e.ref && (n += 'ref:'.concat(e.ref, ',')),
          e.refInFor && (n += 'refInFor:true,'),
          e.pre && (n += 'pre:true,'),
          e.component && (n += 'tag:"'.concat(e.tag, '",'))
        for (var i = 0; i < t.dataGenFns.length; i++) n += t.dataGenFns[i](e)
        if (
          (e.attrs && (n += 'attrs:'.concat(Mo(e.attrs), ',')),
          e.props && (n += 'domProps:'.concat(Mo(e.props), ',')),
          e.events && (n += ''.concat(so(e.events, !1), ',')),
          e.nativeEvents && (n += ''.concat(so(e.nativeEvents, !0), ',')),
          e.slotTarget && !e.slotScope && (n += 'slot:'.concat(e.slotTarget, ',')),
          e.scopedSlots &&
            (n += ''.concat(
              (function (e, t, n) {
                var a =
                    e.for ||
                    Object.keys(t).some(function (e) {
                      var n = t[e]
                      return n.slotTargetDynamic || n.if || n.for || go(n)
                    }),
                  i = !!e.if
                if (!a)
                  for (var r = e.parent; r; ) {
                    if ((r.slotScope && r.slotScope !== Ps) || r.for) {
                      a = !0
                      break
                    }
                    r.if && (i = !0), (r = r.parent)
                  }
                var s = Object.keys(t)
                  .map(function (e) {
                    return wo(t[e], n)
                  })
                  .join(',')
                return 'scopedSlots:_u(['
                  .concat(s, ']')
                  .concat(a ? ',null,true' : '')
                  .concat(
                    !a && i
                      ? ',null,false,'.concat(
                          (function (e) {
                            for (var t = 5381, n = e.length; n; ) t = (33 * t) ^ e.charCodeAt(--n)
                            return t >>> 0
                          })(s)
                        )
                      : '',
                    ')'
                  )
              })(e, e.scopedSlots, t),
              ','
            )),
          e.model &&
            (n += 'model:{value:'
              .concat(e.model.value, ',callback:')
              .concat(e.model.callback, ',expression:')
              .concat(e.model.expression, '},')),
          e.inlineTemplate)
        ) {
          var r = (function (e, t) {
            var n = e.children[0]
            if (n && 1 === n.type) {
              var a = co(n, t.options)
              return 'inlineTemplate:{render:function(){'.concat(a.render, '},staticRenderFns:[').concat(
                a.staticRenderFns
                  .map(function (e) {
                    return 'function(){'.concat(e, '}')
                  })
                  .join(','),
                ']}'
              )
            }
          })(e, t)
          r && (n += ''.concat(r, ','))
        }
        return (
          (n = n.replace(/,$/, '') + '}'),
          e.dynamicAttrs && (n = '_b('.concat(n, ',"').concat(e.tag, '",').concat(Mo(e.dynamicAttrs), ')')),
          e.wrapData && (n = e.wrapData(n)),
          e.wrapListeners && (n = e.wrapListeners(n)),
          n
        )
      }
      function go(e) {
        return 1 === e.type && ('slot' === e.tag || e.children.some(go))
      }
      function wo(e, t) {
        var n = e.attrsMap['slot-scope']
        if (e.if && !e.ifProcessed && !n) return ho(e, t, wo, 'null')
        if (e.for && !e.forProcessed) return To(e, t, wo)
        var a = e.slotScope === Ps ? '' : String(e.slotScope),
          i =
            'function('.concat(a, '){') +
            'return '.concat(
              'template' === e.tag
                ? e.if && n
                  ? '('.concat(e.if, ')?').concat(_o(e, t) || 'undefined', ':undefined')
                  : _o(e, t) || 'undefined'
                : yo(e, t),
              '}'
            ),
          r = a ? '' : ',proxy:true'
        return '{key:'
          .concat(e.slotTarget || '"default"', ',fn:')
          .concat(i)
          .concat(r, '}')
      }
      function _o(e, t, n, a, i) {
        var r = e.children
        if (r.length) {
          var s = r[0]
          if (1 === r.length && s.for && 'template' !== s.tag && 'slot' !== s.tag) {
            var o = n ? (t.maybeComponent(s) ? ',1' : ',0') : ''
            return ''.concat((a || yo)(s, t)).concat(o)
          }
          var u = n
              ? (function (e, t) {
                  for (var n = 0, a = 0; a < e.length; a++) {
                    var i = e[a]
                    if (1 === i.type) {
                      if (
                        ko(i) ||
                        (i.ifConditions &&
                          i.ifConditions.some(function (e) {
                            return ko(e.block)
                          }))
                      ) {
                        n = 2
                        break
                      }
                      ;(t(i) ||
                        (i.ifConditions &&
                          i.ifConditions.some(function (e) {
                            return t(e.block)
                          }))) &&
                        (n = 1)
                    }
                  }
                  return n
                })(r, t.maybeComponent)
              : 0,
            p = i || Ao
          return '['
            .concat(
              r
                .map(function (e) {
                  return p(e, t)
                })
                .join(','),
              ']'
            )
            .concat(u ? ','.concat(u) : '')
        }
      }
      function ko(e) {
        return void 0 !== e.for || 'template' === e.tag || 'slot' === e.tag
      }
      function Ao(e, t) {
        return 1 === e.type
          ? yo(e, t)
          : 3 === e.type && e.isComment
          ? (function (e) {
              return '_e('.concat(JSON.stringify(e.text), ')')
            })(e)
          : '_v('.concat(2 === (n = e).type ? n.expression : Co(JSON.stringify(n.text)), ')')
        var n
      }
      function Mo(e) {
        for (var t = '', n = '', a = 0; a < e.length; a++) {
          var i = e[a],
            r = Co(i.value)
          i.dynamic ? (n += ''.concat(i.name, ',').concat(r, ',')) : (t += '"'.concat(i.name, '":').concat(r, ','))
        }
        return (t = '{'.concat(t.slice(0, -1), '}')), n ? '_d('.concat(t, ',[').concat(n.slice(0, -1), '])') : t
      }
      function Co(e) {
        return e.replace(/\u2028/g, '\\u2028').replace(/\u2029/g, '\\u2029')
      }
      function So(e, t) {
        try {
          return new Function(e)
        } catch (n) {
          return t.push({ err: n, code: e }), I
        }
      }
      function xo(e) {
        var t = Object.create(null)
        return function (n, a, i) {
          ;(a = O({}, a)).warn, delete a.warn
          var r = a.delimiters ? String(a.delimiters) + n : n
          if (t[r]) return t[r]
          var s = e(n, a),
            o = {},
            u = []
          return (
            (o.render = So(s.render, u)),
            (o.staticRenderFns = s.staticRenderFns.map(function (e) {
              return So(e, u)
            })),
            (t[r] = o)
          )
        }
      }
      new RegExp(
        '\\b' +
          'do,if,for,let,new,try,var,case,else,with,await,break,catch,class,const,super,throw,while,yield,delete,export,import,return,switch,default,extends,finally,continue,debugger,function,arguments'
            .split(',')
            .join('\\b|\\b') +
          '\\b'
      ),
        new RegExp('\\b' + 'delete,typeof,void'.split(',').join('\\s*\\([^\\)]*\\)|\\b') + '\\s*\\([^\\)]*\\)')
      var Ro,
        Oo,
        Eo =
          ((Ro = function (e, t) {
            var n = Us(e.trim(), t)
            !1 !== t.optimize && Xs(n, t)
            var a = co(n, t)
            return { ast: n, render: a.render, staticRenderFns: a.staticRenderFns }
          }),
          function (e) {
            function t(t, n) {
              var a = Object.create(e),
                i = [],
                r = []
              if (n)
                for (var s in (n.modules && (a.modules = (e.modules || []).concat(n.modules)),
                n.directives && (a.directives = O(Object.create(e.directives || null), n.directives)),
                n))
                  'modules' !== s && 'directives' !== s && (a[s] = n[s])
              a.warn = function (e, t, n) {
                ;(n ? r : i).push(e)
              }
              var o = Ro(t.trim(), a)
              return (o.errors = i), (o.tips = r), o
            }
            return { compile: t, compileToFunctions: xo(t) }
          }),
        Io = Eo(Ks).compileToFunctions
      function Po(e) {
        return (
          ((Oo = Oo || document.createElement('div')).innerHTML = e ? '<a href="\n"/>' : '<div a="\n"/>'),
          Oo.innerHTML.indexOf('&#10;') > 0
        )
      }
      var Bo = !!G && Po(!1),
        Uo = !!G && Po(!0),
        $o = _(function (e) {
          var t = ka(e)
          return t && t.innerHTML
        }),
        Do = Jn.prototype.$mount
      function Vo(e, t) {
        for (var n in t) e[n] = t[n]
        return e
      }
      ;(Jn.prototype.$mount = function (e, t) {
        if ((e = e && ka(e)) === document.body || e === document.documentElement) return this
        var n = this.$options
        if (!n.render) {
          var a = n.template
          if (a)
            if ('string' == typeof a) '#' === a.charAt(0) && (a = $o(a))
            else {
              if (!a.nodeType) return this
              a = a.innerHTML
            }
          else
            e &&
              (a = (function (e) {
                if (e.outerHTML) return e.outerHTML
                var t = document.createElement('div')
                return t.appendChild(e.cloneNode(!0)), t.innerHTML
              })(e))
          if (a) {
            var i = Io(
                a,
                {
                  outputSourceRange: !1,
                  shouldDecodeNewlines: Bo,
                  shouldDecodeNewlinesForHref: Uo,
                  delimiters: n.delimiters,
                  comments: n.comments,
                },
                this
              ),
              r = i.render,
              s = i.staticRenderFns
            ;(n.render = r), (n.staticRenderFns = s)
          }
        }
        return Do.call(this, e, t)
      }),
        (Jn.compile = Io)
      var No = /[!'()*]/g,
        jo = function (e) {
          return '%' + e.charCodeAt(0).toString(16)
        },
        Fo = /%2C/g,
        Wo = function (e) {
          return encodeURIComponent(e).replace(No, jo).replace(Fo, ',')
        }
      function Lo(e) {
        try {
          return decodeURIComponent(e)
        } catch (e) {}
        return e
      }
      var qo = function (e) {
        return null == e || 'object' == typeof e ? e : String(e)
      }
      function zo(e) {
        var t = {}
        return (e = e.trim().replace(/^(\?|#|&)/, ''))
          ? (e.split('&').forEach(function (e) {
              var n = e.replace(/\+/g, ' ').split('='),
                a = Lo(n.shift()),
                i = n.length > 0 ? Lo(n.join('=')) : null
              void 0 === t[a] ? (t[a] = i) : Array.isArray(t[a]) ? t[a].push(i) : (t[a] = [t[a], i])
            }),
            t)
          : t
      }
      function Ho(e) {
        var t = e
          ? Object.keys(e)
              .map(function (t) {
                var n = e[t]
                if (void 0 === n) return ''
                if (null === n) return Wo(t)
                if (Array.isArray(n)) {
                  var a = []
                  return (
                    n.forEach(function (e) {
                      void 0 !== e && (null === e ? a.push(Wo(t)) : a.push(Wo(t) + '=' + Wo(e)))
                    }),
                    a.join('&')
                  )
                }
                return Wo(t) + '=' + Wo(n)
              })
              .filter(function (e) {
                return e.length > 0
              })
              .join('&')
          : null
        return t ? '?' + t : ''
      }
      var Go = /\/?$/
      function Ko(e, t, n, a) {
        var i = a && a.options.stringifyQuery,
          r = t.query || {}
        try {
          r = Jo(r)
        } catch (e) {}
        var s = {
          name: t.name || (e && e.name),
          meta: (e && e.meta) || {},
          path: t.path || '/',
          hash: t.hash || '',
          query: r,
          params: t.params || {},
          fullPath: Zo(t, i),
          matched: e ? Yo(e) : [],
        }
        return n && (s.redirectedFrom = Zo(n, i)), Object.freeze(s)
      }
      function Jo(e) {
        if (Array.isArray(e)) return e.map(Jo)
        if (e && 'object' == typeof e) {
          var t = {}
          for (var n in e) t[n] = Jo(e[n])
          return t
        }
        return e
      }
      var Xo = Ko(null, { path: '/' })
      function Yo(e) {
        for (var t = []; e; ) t.unshift(e), (e = e.parent)
        return t
      }
      function Zo(e, t) {
        var n = e.path,
          a = e.query
        void 0 === a && (a = {})
        var i = e.hash
        return void 0 === i && (i = ''), (n || '/') + (t || Ho)(a) + i
      }
      function Qo(e, t, n) {
        return t === Xo
          ? e === t
          : !!t &&
              (e.path && t.path
                ? e.path.replace(Go, '') === t.path.replace(Go, '') &&
                  (n || (e.hash === t.hash && eu(e.query, t.query)))
                : !(!e.name || !t.name) &&
                  e.name === t.name &&
                  (n || (e.hash === t.hash && eu(e.query, t.query) && eu(e.params, t.params))))
      }
      function eu(e, t) {
        if ((void 0 === e && (e = {}), void 0 === t && (t = {}), !e || !t)) return e === t
        var n = Object.keys(e).sort(),
          a = Object.keys(t).sort()
        return (
          n.length === a.length &&
          n.every(function (n, i) {
            var r = e[n]
            if (a[i] !== n) return !1
            var s = t[n]
            return null == r || null == s
              ? r === s
              : 'object' == typeof r && 'object' == typeof s
              ? eu(r, s)
              : String(r) === String(s)
          })
        )
      }
      function tu(e) {
        for (var t = 0; t < e.matched.length; t++) {
          var n = e.matched[t]
          for (var a in n.instances) {
            var i = n.instances[a],
              r = n.enteredCbs[a]
            if (i && r) {
              delete n.enteredCbs[a]
              for (var s = 0; s < r.length; s++) i._isBeingDestroyed || r[s](i)
            }
          }
        }
      }
      var nu = {
        name: 'RouterView',
        functional: !0,
        props: { name: { type: String, default: 'default' } },
        render: function (e, t) {
          var n = t.props,
            a = t.children,
            i = t.parent,
            r = t.data
          r.routerView = !0
          for (
            var s = i.$createElement,
              o = n.name,
              u = i.$route,
              p = i._routerViewCache || (i._routerViewCache = {}),
              l = 0,
              d = !1;
            i && i._routerRoot !== i;

          ) {
            var c = i.$vnode ? i.$vnode.data : {}
            c.routerView && l++, c.keepAlive && i._directInactive && i._inactive && (d = !0), (i = i.$parent)
          }
          if (((r.routerViewDepth = l), d)) {
            var y = p[o],
              f = y && y.component
            return f ? (y.configProps && au(f, r, y.route, y.configProps), s(f, r, a)) : s()
          }
          var m = u.matched[l],
            h = m && m.components[o]
          if (!m || !h) return (p[o] = null), s()
          ;(p[o] = { component: h }),
            (r.registerRouteInstance = function (e, t) {
              var n = m.instances[o]
              ;((t && n !== e) || (!t && n === e)) && (m.instances[o] = t)
            }),
            ((r.hook || (r.hook = {})).prepatch = function (e, t) {
              m.instances[o] = t.componentInstance
            }),
            (r.hook.init = function (e) {
              e.data.keepAlive &&
                e.componentInstance &&
                e.componentInstance !== m.instances[o] &&
                (m.instances[o] = e.componentInstance),
                tu(u)
            })
          var v = m.props && m.props[o]
          return v && (Vo(p[o], { route: u, configProps: v }), au(h, r, u, v)), s(h, r, a)
        },
      }
      function au(e, t, n, a) {
        var i = (t.props = (function (e, t) {
          switch (typeof t) {
            case 'undefined':
              return
            case 'object':
              return t
            case 'function':
              return t(e)
            case 'boolean':
              return t ? e.params : void 0
          }
        })(n, a))
        if (i) {
          i = t.props = Vo({}, i)
          var r = (t.attrs = t.attrs || {})
          for (var s in i) (e.props && s in e.props) || ((r[s] = i[s]), delete i[s])
        }
      }
      function iu(e, t, n) {
        var a = e.charAt(0)
        if ('/' === a) return e
        if ('?' === a || '#' === a) return t + e
        var i = t.split('/')
        ;(n && i[i.length - 1]) || i.pop()
        for (var r = e.replace(/^\//, '').split('/'), s = 0; s < r.length; s++) {
          var o = r[s]
          '..' === o ? i.pop() : '.' !== o && i.push(o)
        }
        return '' !== i[0] && i.unshift(''), i.join('/')
      }
      function ru(e) {
        return e.replace(/\/(?:\s*\/)+/g, '/')
      }
      var su =
          Array.isArray ||
          function (e) {
            return '[object Array]' == Object.prototype.toString.call(e)
          },
        ou = function e(t, n, a) {
          return (
            su(n) || ((a = n || a), (n = [])),
            (a = a || {}),
            t instanceof RegExp
              ? (function (e, t) {
                  var n = e.source.match(/\((?!\?)/g)
                  if (n)
                    for (var a = 0; a < n.length; a++)
                      t.push({
                        name: a,
                        prefix: null,
                        delimiter: null,
                        optional: !1,
                        repeat: !1,
                        partial: !1,
                        asterisk: !1,
                        pattern: null,
                      })
                  return Tu(e, t)
                })(t, n)
              : su(t)
              ? (function (t, n, a) {
                  for (var i = [], r = 0; r < t.length; r++) i.push(e(t[r], n, a).source)
                  return Tu(new RegExp('(?:' + i.join('|') + ')', bu(a)), n)
                })(t, n, a)
              : (function (e, t, n) {
                  return gu(cu(e, n), t, n)
                })(t, n, a)
          )
        },
        uu = cu,
        pu = mu,
        lu = gu,
        du = new RegExp(
          [
            '(\\\\.)',
            '([\\/.])?(?:(?:\\:(\\w+)(?:\\(((?:\\\\.|[^\\\\()])+)\\))?|\\(((?:\\\\.|[^\\\\()])+)\\))([+*?])?|(\\*))',
          ].join('|'),
          'g'
        )
      function cu(e, t) {
        for (var n, a = [], i = 0, r = 0, s = '', o = (t && t.delimiter) || '/'; null != (n = du.exec(e)); ) {
          var u = n[0],
            p = n[1],
            l = n.index
          if (((s += e.slice(r, l)), (r = l + u.length), p)) s += p[1]
          else {
            var d = e[r],
              c = n[2],
              y = n[3],
              f = n[4],
              m = n[5],
              h = n[6],
              v = n[7]
            s && (a.push(s), (s = ''))
            var T = null != c && null != d && d !== c,
              b = '+' === h || '*' === h,
              g = '?' === h || '*' === h,
              w = n[2] || o,
              _ = f || m
            a.push({
              name: y || i++,
              prefix: c || '',
              delimiter: w,
              optional: g,
              repeat: b,
              partial: T,
              asterisk: !!v,
              pattern: _ ? vu(_) : v ? '.*' : '[^' + hu(w) + ']+?',
            })
          }
        }
        return r < e.length && (s += e.substr(r)), s && a.push(s), a
      }
      function yu(e) {
        return encodeURI(e).replace(/[\/?#]/g, function (e) {
          return '%' + e.charCodeAt(0).toString(16).toUpperCase()
        })
      }
      function fu(e) {
        return encodeURI(e).replace(/[?#]/g, function (e) {
          return '%' + e.charCodeAt(0).toString(16).toUpperCase()
        })
      }
      function mu(e, t) {
        for (var n = new Array(e.length), a = 0; a < e.length; a++)
          'object' == typeof e[a] && (n[a] = new RegExp('^(?:' + e[a].pattern + ')$', bu(t)))
        return function (t, a) {
          for (var i = '', r = t || {}, s = (a || {}).pretty ? yu : encodeURIComponent, o = 0; o < e.length; o++) {
            var u = e[o]
            if ('string' != typeof u) {
              var p,
                l = r[u.name]
              if (null == l) {
                if (u.optional) {
                  u.partial && (i += u.prefix)
                  continue
                }
                throw new TypeError('Expected "' + u.name + '" to be defined')
              }
              if (su(l)) {
                if (!u.repeat)
                  throw new TypeError(
                    'Expected "' + u.name + '" to not repeat, but received `' + JSON.stringify(l) + '`'
                  )
                if (0 === l.length) {
                  if (u.optional) continue
                  throw new TypeError('Expected "' + u.name + '" to not be empty')
                }
                for (var d = 0; d < l.length; d++) {
                  if (((p = s(l[d])), !n[o].test(p)))
                    throw new TypeError(
                      'Expected all "' +
                        u.name +
                        '" to match "' +
                        u.pattern +
                        '", but received `' +
                        JSON.stringify(p) +
                        '`'
                    )
                  i += (0 === d ? u.prefix : u.delimiter) + p
                }
              } else {
                if (((p = u.asterisk ? fu(l) : s(l)), !n[o].test(p)))
                  throw new TypeError(
                    'Expected "' + u.name + '" to match "' + u.pattern + '", but received "' + p + '"'
                  )
                i += u.prefix + p
              }
            } else i += u
          }
          return i
        }
      }
      function hu(e) {
        return e.replace(/([.+*?=^!:${}()[\]|\/\\])/g, '\\$1')
      }
      function vu(e) {
        return e.replace(/([=!:$\/()])/g, '\\$1')
      }
      function Tu(e, t) {
        return (e.keys = t), e
      }
      function bu(e) {
        return e && e.sensitive ? '' : 'i'
      }
      function gu(e, t, n) {
        su(t) || ((n = t || n), (t = []))
        for (var a = (n = n || {}).strict, i = !1 !== n.end, r = '', s = 0; s < e.length; s++) {
          var o = e[s]
          if ('string' == typeof o) r += hu(o)
          else {
            var u = hu(o.prefix),
              p = '(?:' + o.pattern + ')'
            t.push(o),
              o.repeat && (p += '(?:' + u + p + ')*'),
              (r += p = o.optional ? (o.partial ? u + '(' + p + ')?' : '(?:' + u + '(' + p + '))?') : u + '(' + p + ')')
          }
        }
        var l = hu(n.delimiter || '/'),
          d = r.slice(-l.length) === l
        return (
          a || (r = (d ? r.slice(0, -l.length) : r) + '(?:' + l + '(?=$))?'),
          (r += i ? '$' : a && d ? '' : '(?=' + l + '|$)'),
          Tu(new RegExp('^' + r, bu(n)), t)
        )
      }
      ;(ou.parse = uu),
        (ou.compile = function (e, t) {
          return mu(cu(e, t), t)
        }),
        (ou.tokensToFunction = pu),
        (ou.tokensToRegExp = lu)
      var wu = Object.create(null)
      function _u(e, t, n) {
        t = t || {}
        try {
          var a = wu[e] || (wu[e] = ou.compile(e))
          return 'string' == typeof t.pathMatch && (t[0] = t.pathMatch), a(t, { pretty: !0 })
        } catch (e) {
          return ''
        } finally {
          delete t[0]
        }
      }
      function ku(e, t, n, a) {
        var i = 'string' == typeof e ? { path: e } : e
        if (i._normalized) return i
        if (i.name) {
          var r = (i = Vo({}, e)).params
          return r && 'object' == typeof r && (i.params = Vo({}, r)), i
        }
        if (!i.path && i.params && t) {
          ;(i = Vo({}, i))._normalized = !0
          var s = Vo(Vo({}, t.params), i.params)
          if (t.name) (i.name = t.name), (i.params = s)
          else if (t.matched.length) {
            var o = t.matched[t.matched.length - 1].path
            i.path = _u(o, s, t.path)
          }
          return i
        }
        var u = (function (e) {
            var t = '',
              n = '',
              a = e.indexOf('#')
            a >= 0 && ((t = e.slice(a)), (e = e.slice(0, a)))
            var i = e.indexOf('?')
            return i >= 0 && ((n = e.slice(i + 1)), (e = e.slice(0, i))), { path: e, query: n, hash: t }
          })(i.path || ''),
          p = (t && t.path) || '/',
          l = u.path ? iu(u.path, p, n || i.append) : p,
          d = (function (e, t, n) {
            void 0 === t && (t = {})
            var a,
              i = n || zo
            try {
              a = i(e || '')
            } catch (e) {
              a = {}
            }
            for (var r in t) {
              var s = t[r]
              a[r] = Array.isArray(s) ? s.map(qo) : qo(s)
            }
            return a
          })(u.query, i.query, a && a.options.parseQuery),
          c = i.hash || u.hash
        return c && '#' !== c.charAt(0) && (c = '#' + c), { _normalized: !0, path: l, query: d, hash: c }
      }
      var Au,
        Mu = function () {},
        Cu = {
          name: 'RouterLink',
          props: {
            to: { type: [String, Object], required: !0 },
            tag: { type: String, default: 'a' },
            custom: Boolean,
            exact: Boolean,
            exactPath: Boolean,
            append: Boolean,
            replace: Boolean,
            activeClass: String,
            exactActiveClass: String,
            ariaCurrentValue: { type: String, default: 'page' },
            event: { type: [String, Array], default: 'click' },
          },
          render: function (e) {
            var t = this,
              n = this.$router,
              a = this.$route,
              i = n.resolve(this.to, a, this.append),
              r = i.location,
              s = i.route,
              o = i.href,
              u = {},
              p = n.options.linkActiveClass,
              l = n.options.linkExactActiveClass,
              d = null == p ? 'router-link-active' : p,
              c = null == l ? 'router-link-exact-active' : l,
              y = null == this.activeClass ? d : this.activeClass,
              f = null == this.exactActiveClass ? c : this.exactActiveClass,
              m = s.redirectedFrom ? Ko(null, ku(s.redirectedFrom), null, n) : s
            ;(u[f] = Qo(a, m, this.exactPath)),
              (u[y] =
                this.exact || this.exactPath
                  ? u[f]
                  : (function (e, t) {
                      return (
                        0 === e.path.replace(Go, '/').indexOf(t.path.replace(Go, '/')) &&
                        (!t.hash || e.hash === t.hash) &&
                        (function (e, t) {
                          for (var n in t) if (!(n in e)) return !1
                          return !0
                        })(e.query, t.query)
                      )
                    })(a, m))
            var h = u[f] ? this.ariaCurrentValue : null,
              v = function (e) {
                Su(e) && (t.replace ? n.replace(r, Mu) : n.push(r, Mu))
              },
              T = { click: Su }
            Array.isArray(this.event)
              ? this.event.forEach(function (e) {
                  T[e] = v
                })
              : (T[this.event] = v)
            var b = { class: u },
              g =
                !this.$scopedSlots.$hasNormal &&
                this.$scopedSlots.default &&
                this.$scopedSlots.default({ href: o, route: s, navigate: v, isActive: u[y], isExactActive: u[f] })
            if (g) {
              if (1 === g.length) return g[0]
              if (g.length > 1 || !g.length) return 0 === g.length ? e() : e('span', {}, g)
            }
            if ('a' === this.tag) (b.on = T), (b.attrs = { href: o, 'aria-current': h })
            else {
              var w = xu(this.$slots.default)
              if (w) {
                w.isStatic = !1
                var _ = (w.data = Vo({}, w.data))
                for (var k in ((_.on = _.on || {}), _.on)) {
                  var A = _.on[k]
                  k in T && (_.on[k] = Array.isArray(A) ? A : [A])
                }
                for (var M in T) M in _.on ? _.on[M].push(T[M]) : (_.on[M] = v)
                var C = (w.data.attrs = Vo({}, w.data.attrs))
                ;(C.href = o), (C['aria-current'] = h)
              } else b.on = T
            }
            return e(this.tag, b, this.$slots.default)
          },
        }
      function Su(e) {
        if (
          !(
            e.metaKey ||
            e.altKey ||
            e.ctrlKey ||
            e.shiftKey ||
            e.defaultPrevented ||
            (void 0 !== e.button && 0 !== e.button)
          )
        ) {
          if (e.currentTarget && e.currentTarget.getAttribute) {
            var t = e.currentTarget.getAttribute('target')
            if (/\b_blank\b/i.test(t)) return
          }
          return e.preventDefault && e.preventDefault(), !0
        }
      }
      function xu(e) {
        if (e)
          for (var t, n = 0; n < e.length; n++) {
            if ('a' === (t = e[n]).tag) return t
            if (t.children && (t = xu(t.children))) return t
          }
      }
      var Ru = 'undefined' != typeof window
      function Ou(e, t, n, a, i) {
        var r = t || [],
          s = n || Object.create(null),
          o = a || Object.create(null)
        e.forEach(function (e) {
          Eu(r, s, o, e, i)
        })
        for (var u = 0, p = r.length; u < p; u++) '*' === r[u] && (r.push(r.splice(u, 1)[0]), p--, u--)
        return { pathList: r, pathMap: s, nameMap: o }
      }
      function Eu(e, t, n, a, i, r) {
        var s = a.path,
          o = a.name,
          u = a.pathToRegexpOptions || {},
          p = (function (e, t, n) {
            return n || (e = e.replace(/\/$/, '')), '/' === e[0] || null == t ? e : ru(t.path + '/' + e)
          })(s, i, u.strict)
        'boolean' == typeof a.caseSensitive && (u.sensitive = a.caseSensitive)
        var l = {
          path: p,
          regex: Iu(p, u),
          components: a.components || { default: a.component },
          alias: a.alias ? ('string' == typeof a.alias ? [a.alias] : a.alias) : [],
          instances: {},
          enteredCbs: {},
          name: o,
          parent: i,
          matchAs: r,
          redirect: a.redirect,
          beforeEnter: a.beforeEnter,
          meta: a.meta || {},
          props: null == a.props ? {} : a.components ? a.props : { default: a.props },
        }
        if (
          (a.children &&
            a.children.forEach(function (a) {
              var i = r ? ru(r + '/' + a.path) : void 0
              Eu(e, t, n, a, l, i)
            }),
          t[l.path] || (e.push(l.path), (t[l.path] = l)),
          void 0 !== a.alias)
        )
          for (var d = Array.isArray(a.alias) ? a.alias : [a.alias], c = 0; c < d.length; ++c) {
            var y = { path: d[c], children: a.children }
            Eu(e, t, n, y, i, l.path || '/')
          }
        o && (n[o] || (n[o] = l))
      }
      function Iu(e, t) {
        return ou(e, [], t)
      }
      function Pu(e, t) {
        var n = Ou(e),
          a = n.pathList,
          i = n.pathMap,
          r = n.nameMap
        function s(e, n, s) {
          var u = ku(e, n, !1, t),
            p = u.name
          if (p) {
            var l = r[p]
            if (!l) return o(null, u)
            var d = l.regex.keys
              .filter(function (e) {
                return !e.optional
              })
              .map(function (e) {
                return e.name
              })
            if (('object' != typeof u.params && (u.params = {}), n && 'object' == typeof n.params))
              for (var c in n.params) !(c in u.params) && d.indexOf(c) > -1 && (u.params[c] = n.params[c])
            return (u.path = _u(l.path, u.params)), o(l, u, s)
          }
          if (u.path) {
            u.params = {}
            for (var y = 0; y < a.length; y++) {
              var f = a[y],
                m = i[f]
              if (Bu(m.regex, u.path, u.params)) return o(m, u, s)
            }
          }
          return o(null, u)
        }
        function o(e, n, a) {
          return e && e.redirect
            ? (function (e, n) {
                var a = e.redirect,
                  i = 'function' == typeof a ? a(Ko(e, n, null, t)) : a
                if (('string' == typeof i && (i = { path: i }), !i || 'object' != typeof i)) return o(null, n)
                var u = i,
                  p = u.name,
                  l = u.path,
                  d = n.query,
                  c = n.hash,
                  y = n.params
                if (
                  ((d = u.hasOwnProperty('query') ? u.query : d),
                  (c = u.hasOwnProperty('hash') ? u.hash : c),
                  (y = u.hasOwnProperty('params') ? u.params : y),
                  p)
                )
                  return r[p], s({ _normalized: !0, name: p, query: d, hash: c, params: y }, void 0, n)
                if (l) {
                  var f = (function (e, t) {
                    return iu(e, t.parent ? t.parent.path : '/', !0)
                  })(l, e)
                  return s({ _normalized: !0, path: _u(f, y), query: d, hash: c }, void 0, n)
                }
                return o(null, n)
              })(e, a || n)
            : e && e.matchAs
            ? (function (e, t, n) {
                var a = s({ _normalized: !0, path: _u(n, t.params) })
                if (a) {
                  var i = a.matched,
                    r = i[i.length - 1]
                  return (t.params = a.params), o(r, t)
                }
                return o(null, t)
              })(0, n, e.matchAs)
            : Ko(e, n, a, t)
        }
        return {
          match: s,
          addRoute: function (e, t) {
            var n = 'object' != typeof e ? r[e] : void 0
            Ou([t || e], a, i, r, n),
              n &&
                n.alias.length &&
                Ou(
                  n.alias.map(function (e) {
                    return { path: e, children: [t] }
                  }),
                  a,
                  i,
                  r,
                  n
                )
          },
          getRoutes: function () {
            return a.map(function (e) {
              return i[e]
            })
          },
          addRoutes: function (e) {
            Ou(e, a, i, r)
          },
        }
      }
      function Bu(e, t, n) {
        var a = t.match(e)
        if (!a) return !1
        if (!n) return !0
        for (var i = 1, r = a.length; i < r; ++i) {
          var s = e.keys[i - 1]
          s && (n[s.name || 'pathMatch'] = 'string' == typeof a[i] ? Lo(a[i]) : a[i])
        }
        return !0
      }
      var Uu = Ru && window.performance && window.performance.now ? window.performance : Date
      function $u() {
        return Uu.now().toFixed(3)
      }
      var Du = $u()
      function Vu() {
        return Du
      }
      function Nu(e) {
        return (Du = e)
      }
      var ju = Object.create(null)
      function Fu() {
        'scrollRestoration' in window.history && (window.history.scrollRestoration = 'manual')
        var e = window.location.protocol + '//' + window.location.host,
          t = window.location.href.replace(e, ''),
          n = Vo({}, window.history.state)
        return (
          (n.key = Vu()),
          window.history.replaceState(n, '', t),
          window.addEventListener('popstate', qu),
          function () {
            window.removeEventListener('popstate', qu)
          }
        )
      }
      function Wu(e, t, n, a) {
        if (e.app) {
          var i = e.options.scrollBehavior
          i &&
            e.app.$nextTick(function () {
              var r = (function () {
                  var e = Vu()
                  if (e) return ju[e]
                })(),
                s = i.call(e, t, n, a ? r : null)
              s &&
                ('function' == typeof s.then
                  ? s
                      .then(function (e) {
                        Ju(e, r)
                      })
                      .catch(function (e) {})
                  : Ju(s, r))
            })
        }
      }
      function Lu() {
        var e = Vu()
        e && (ju[e] = { x: window.pageXOffset, y: window.pageYOffset })
      }
      function qu(e) {
        Lu(), e.state && e.state.key && Nu(e.state.key)
      }
      function zu(e) {
        return Gu(e.x) || Gu(e.y)
      }
      function Hu(e) {
        return { x: Gu(e.x) ? e.x : window.pageXOffset, y: Gu(e.y) ? e.y : window.pageYOffset }
      }
      function Gu(e) {
        return 'number' == typeof e
      }
      var Ku = /^#\d/
      function Ju(e, t) {
        var n,
          a = 'object' == typeof e
        if (a && 'string' == typeof e.selector) {
          var i = Ku.test(e.selector)
            ? document.getElementById(e.selector.slice(1))
            : document.querySelector(e.selector)
          if (i) {
            var r = e.offset && 'object' == typeof e.offset ? e.offset : {}
            t = (function (e, t) {
              var n = document.documentElement.getBoundingClientRect(),
                a = e.getBoundingClientRect()
              return { x: a.left - n.left - t.x, y: a.top - n.top - t.y }
            })(i, (r = { x: Gu((n = r).x) ? n.x : 0, y: Gu(n.y) ? n.y : 0 }))
          } else zu(e) && (t = Hu(e))
        } else a && zu(e) && (t = Hu(e))
        t &&
          ('scrollBehavior' in document.documentElement.style
            ? window.scrollTo({ left: t.x, top: t.y, behavior: e.behavior })
            : window.scrollTo(t.x, t.y))
      }
      var Xu,
        Yu =
          Ru &&
          ((-1 === (Xu = window.navigator.userAgent).indexOf('Android 2.') && -1 === Xu.indexOf('Android 4.0')) ||
            -1 === Xu.indexOf('Mobile Safari') ||
            -1 !== Xu.indexOf('Chrome') ||
            -1 !== Xu.indexOf('Windows Phone')) &&
          window.history &&
          'function' == typeof window.history.pushState
      function Zu(e, t) {
        Lu()
        var n = window.history
        try {
          if (t) {
            var a = Vo({}, n.state)
            ;(a.key = Vu()), n.replaceState(a, '', e)
          } else n.pushState({ key: Nu($u()) }, '', e)
        } catch (n) {
          window.location[t ? 'replace' : 'assign'](e)
        }
      }
      function Qu(e) {
        Zu(e, !0)
      }
      var ep = { redirected: 2, aborted: 4, cancelled: 8, duplicated: 16 }
      function tp(e, t) {
        return np(
          e,
          t,
          ep.cancelled,
          'Navigation cancelled from "' + e.fullPath + '" to "' + t.fullPath + '" with a new navigation.'
        )
      }
      function np(e, t, n, a) {
        var i = new Error(a)
        return (i._isRouter = !0), (i.from = e), (i.to = t), (i.type = n), i
      }
      var ap = ['params', 'query', 'hash']
      function ip(e) {
        return Object.prototype.toString.call(e).indexOf('Error') > -1
      }
      function rp(e, t) {
        return ip(e) && e._isRouter && (null == t || e.type === t)
      }
      function sp(e, t, n) {
        var a = function (i) {
          i >= e.length
            ? n()
            : e[i]
            ? t(e[i], function () {
                a(i + 1)
              })
            : a(i + 1)
        }
        a(0)
      }
      function op(e, t) {
        return up(
          e.map(function (e) {
            return Object.keys(e.components).map(function (n) {
              return t(e.components[n], e.instances[n], e, n)
            })
          })
        )
      }
      function up(e) {
        return Array.prototype.concat.apply([], e)
      }
      var pp = 'function' == typeof Symbol && 'symbol' == typeof Symbol.toStringTag
      function lp(e) {
        var t = !1
        return function () {
          for (var n = [], a = arguments.length; a--; ) n[a] = arguments[a]
          if (!t) return (t = !0), e.apply(this, n)
        }
      }
      var dp = function (e, t) {
        ;(this.router = e),
          (this.base = (function (e) {
            if (!e)
              if (Ru) {
                var t = document.querySelector('base')
                e = (e = (t && t.getAttribute('href')) || '/').replace(/^https?:\/\/[^\/]+/, '')
              } else e = '/'
            return '/' !== e.charAt(0) && (e = '/' + e), e.replace(/\/$/, '')
          })(t)),
          (this.current = Xo),
          (this.pending = null),
          (this.ready = !1),
          (this.readyCbs = []),
          (this.readyErrorCbs = []),
          (this.errorCbs = []),
          (this.listeners = [])
      }
      function cp(e, t, n, a) {
        var i = op(e, function (e, a, i, r) {
          var s = (function (e, t) {
            return 'function' != typeof e && (e = Au.extend(e)), e.options[t]
          })(e, t)
          if (s)
            return Array.isArray(s)
              ? s.map(function (e) {
                  return n(e, a, i, r)
                })
              : n(s, a, i, r)
        })
        return up(a ? i.reverse() : i)
      }
      function yp(e, t) {
        if (t)
          return function () {
            return e.apply(t, arguments)
          }
      }
      ;(dp.prototype.listen = function (e) {
        this.cb = e
      }),
        (dp.prototype.onReady = function (e, t) {
          this.ready ? e() : (this.readyCbs.push(e), t && this.readyErrorCbs.push(t))
        }),
        (dp.prototype.onError = function (e) {
          this.errorCbs.push(e)
        }),
        (dp.prototype.transitionTo = function (e, t, n) {
          var a,
            i = this
          try {
            a = this.router.match(e, this.current)
          } catch (e) {
            throw (
              (this.errorCbs.forEach(function (t) {
                t(e)
              }),
              e)
            )
          }
          var r = this.current
          this.confirmTransition(
            a,
            function () {
              i.updateRoute(a),
                t && t(a),
                i.ensureURL(),
                i.router.afterHooks.forEach(function (e) {
                  e && e(a, r)
                }),
                i.ready ||
                  ((i.ready = !0),
                  i.readyCbs.forEach(function (e) {
                    e(a)
                  }))
            },
            function (e) {
              n && n(e),
                e &&
                  !i.ready &&
                  ((rp(e, ep.redirected) && r === Xo) ||
                    ((i.ready = !0),
                    i.readyErrorCbs.forEach(function (t) {
                      t(e)
                    })))
            }
          )
        }),
        (dp.prototype.confirmTransition = function (e, t, n) {
          var a = this,
            i = this.current
          this.pending = e
          var r,
            s,
            o = function (e) {
              !rp(e) &&
                ip(e) &&
                (a.errorCbs.length
                  ? a.errorCbs.forEach(function (t) {
                      t(e)
                    })
                  : console.error(e)),
                n && n(e)
            },
            u = e.matched.length - 1,
            p = i.matched.length - 1
          if (Qo(e, i) && u === p && e.matched[u] === i.matched[p])
            return (
              this.ensureURL(),
              e.hash && Wu(this.router, i, e, !1),
              o(
                (((s = np(
                  (r = i),
                  e,
                  ep.duplicated,
                  'Avoided redundant navigation to current location: "' + r.fullPath + '".'
                )).name = 'NavigationDuplicated'),
                s)
              )
            )
          var l,
            d = (function (e, t) {
              var n,
                a = Math.max(e.length, t.length)
              for (n = 0; n < a && e[n] === t[n]; n++);
              return { updated: t.slice(0, n), activated: t.slice(n), deactivated: e.slice(n) }
            })(this.current.matched, e.matched),
            c = d.updated,
            y = d.deactivated,
            f = d.activated,
            m = [].concat(
              (function (e) {
                return cp(e, 'beforeRouteLeave', yp, !0)
              })(y),
              this.router.beforeHooks,
              (function (e) {
                return cp(e, 'beforeRouteUpdate', yp)
              })(c),
              f.map(function (e) {
                return e.beforeEnter
              }),
              ((l = f),
              function (e, t, n) {
                var a = !1,
                  i = 0,
                  r = null
                op(l, function (e, t, s, o) {
                  if ('function' == typeof e && void 0 === e.cid) {
                    ;(a = !0), i++
                    var u,
                      p = lp(function (t) {
                        var a
                        ;((a = t).__esModule || (pp && 'Module' === a[Symbol.toStringTag])) && (t = t.default),
                          (e.resolved = 'function' == typeof t ? t : Au.extend(t)),
                          (s.components[o] = t),
                          --i <= 0 && n()
                      }),
                      l = lp(function (e) {
                        var t = 'Failed to resolve async component ' + o + ': ' + e
                        r || ((r = ip(e) ? e : new Error(t)), n(r))
                      })
                    try {
                      u = e(p, l)
                    } catch (e) {
                      l(e)
                    }
                    if (u)
                      if ('function' == typeof u.then) u.then(p, l)
                      else {
                        var d = u.component
                        d && 'function' == typeof d.then && d.then(p, l)
                      }
                  }
                }),
                  a || n()
              })
            ),
            h = function (t, n) {
              if (a.pending !== e) return o(tp(i, e))
              try {
                t(e, i, function (t) {
                  !1 === t
                    ? (a.ensureURL(!0),
                      o(
                        (function (e, t) {
                          return np(
                            e,
                            t,
                            ep.aborted,
                            'Navigation aborted from "' +
                              e.fullPath +
                              '" to "' +
                              t.fullPath +
                              '" via a navigation guard.'
                          )
                        })(i, e)
                      ))
                    : ip(t)
                    ? (a.ensureURL(!0), o(t))
                    : 'string' == typeof t ||
                      ('object' == typeof t && ('string' == typeof t.path || 'string' == typeof t.name))
                    ? (o(
                        (function (e, t) {
                          return np(
                            e,
                            t,
                            ep.redirected,
                            'Redirected when going from "' +
                              e.fullPath +
                              '" to "' +
                              (function (e) {
                                if ('string' == typeof e) return e
                                if ('path' in e) return e.path
                                var t = {}
                                return (
                                  ap.forEach(function (n) {
                                    n in e && (t[n] = e[n])
                                  }),
                                  JSON.stringify(t, null, 2)
                                )
                              })(t) +
                              '" via a navigation guard.'
                          )
                        })(i, e)
                      ),
                      'object' == typeof t && t.replace ? a.replace(t) : a.push(t))
                    : n(t)
                })
              } catch (e) {
                o(e)
              }
            }
          sp(m, h, function () {
            var n = (function (e) {
              return cp(e, 'beforeRouteEnter', function (e, t, n, a) {
                return (function (e, t, n) {
                  return function (a, i, r) {
                    return e(a, i, function (e) {
                      'function' == typeof e && (t.enteredCbs[n] || (t.enteredCbs[n] = []), t.enteredCbs[n].push(e)),
                        r(e)
                    })
                  }
                })(e, n, a)
              })
            })(f)
            sp(n.concat(a.router.resolveHooks), h, function () {
              if (a.pending !== e) return o(tp(i, e))
              ;(a.pending = null),
                t(e),
                a.router.app &&
                  a.router.app.$nextTick(function () {
                    tu(e)
                  })
            })
          })
        }),
        (dp.prototype.updateRoute = function (e) {
          ;(this.current = e), this.cb && this.cb(e)
        }),
        (dp.prototype.setupListeners = function () {}),
        (dp.prototype.teardown = function () {
          this.listeners.forEach(function (e) {
            e()
          }),
            (this.listeners = []),
            (this.current = Xo),
            (this.pending = null)
        })
      var fp = (function (e) {
        function t(t, n) {
          e.call(this, t, n), (this._startLocation = mp(this.base))
        }
        return (
          e && (t.__proto__ = e),
          (t.prototype = Object.create(e && e.prototype)),
          (t.prototype.constructor = t),
          (t.prototype.setupListeners = function () {
            var e = this
            if (!(this.listeners.length > 0)) {
              var t = this.router,
                n = t.options.scrollBehavior,
                a = Yu && n
              a && this.listeners.push(Fu())
              var i = function () {
                var n = e.current,
                  i = mp(e.base)
                ;(e.current === Xo && i === e._startLocation) ||
                  e.transitionTo(i, function (e) {
                    a && Wu(t, e, n, !0)
                  })
              }
              window.addEventListener('popstate', i),
                this.listeners.push(function () {
                  window.removeEventListener('popstate', i)
                })
            }
          }),
          (t.prototype.go = function (e) {
            window.history.go(e)
          }),
          (t.prototype.push = function (e, t, n) {
            var a = this,
              i = this.current
            this.transitionTo(
              e,
              function (e) {
                Zu(ru(a.base + e.fullPath)), Wu(a.router, e, i, !1), t && t(e)
              },
              n
            )
          }),
          (t.prototype.replace = function (e, t, n) {
            var a = this,
              i = this.current
            this.transitionTo(
              e,
              function (e) {
                Qu(ru(a.base + e.fullPath)), Wu(a.router, e, i, !1), t && t(e)
              },
              n
            )
          }),
          (t.prototype.ensureURL = function (e) {
            if (mp(this.base) !== this.current.fullPath) {
              var t = ru(this.base + this.current.fullPath)
              e ? Zu(t) : Qu(t)
            }
          }),
          (t.prototype.getCurrentLocation = function () {
            return mp(this.base)
          }),
          t
        )
      })(dp)
      function mp(e) {
        var t = window.location.pathname,
          n = t.toLowerCase(),
          a = e.toLowerCase()
        return (
          !e || (n !== a && 0 !== n.indexOf(ru(a + '/'))) || (t = t.slice(e.length)),
          (t || '/') + window.location.search + window.location.hash
        )
      }
      var hp = (function (e) {
        function t(t, n, a) {
          e.call(this, t, n),
            (a &&
              (function (e) {
                var t = mp(e)
                if (!/^\/#/.test(t)) return window.location.replace(ru(e + '/#' + t)), !0
              })(this.base)) ||
              vp()
        }
        return (
          e && (t.__proto__ = e),
          (t.prototype = Object.create(e && e.prototype)),
          (t.prototype.constructor = t),
          (t.prototype.setupListeners = function () {
            var e = this
            if (!(this.listeners.length > 0)) {
              var t = this.router.options.scrollBehavior,
                n = Yu && t
              n && this.listeners.push(Fu())
              var a = function () {
                  var t = e.current
                  vp() &&
                    e.transitionTo(Tp(), function (a) {
                      n && Wu(e.router, a, t, !0), Yu || wp(a.fullPath)
                    })
                },
                i = Yu ? 'popstate' : 'hashchange'
              window.addEventListener(i, a),
                this.listeners.push(function () {
                  window.removeEventListener(i, a)
                })
            }
          }),
          (t.prototype.push = function (e, t, n) {
            var a = this,
              i = this.current
            this.transitionTo(
              e,
              function (e) {
                gp(e.fullPath), Wu(a.router, e, i, !1), t && t(e)
              },
              n
            )
          }),
          (t.prototype.replace = function (e, t, n) {
            var a = this,
              i = this.current
            this.transitionTo(
              e,
              function (e) {
                wp(e.fullPath), Wu(a.router, e, i, !1), t && t(e)
              },
              n
            )
          }),
          (t.prototype.go = function (e) {
            window.history.go(e)
          }),
          (t.prototype.ensureURL = function (e) {
            var t = this.current.fullPath
            Tp() !== t && (e ? gp(t) : wp(t))
          }),
          (t.prototype.getCurrentLocation = function () {
            return Tp()
          }),
          t
        )
      })(dp)
      function vp() {
        var e = Tp()
        return '/' === e.charAt(0) || (wp('/' + e), !1)
      }
      function Tp() {
        var e = window.location.href,
          t = e.indexOf('#')
        return t < 0 ? '' : (e = e.slice(t + 1))
      }
      function bp(e) {
        var t = window.location.href,
          n = t.indexOf('#')
        return (n >= 0 ? t.slice(0, n) : t) + '#' + e
      }
      function gp(e) {
        Yu ? Zu(bp(e)) : (window.location.hash = e)
      }
      function wp(e) {
        Yu ? Qu(bp(e)) : window.location.replace(bp(e))
      }
      var _p = (function (e) {
          function t(t, n) {
            e.call(this, t, n), (this.stack = []), (this.index = -1)
          }
          return (
            e && (t.__proto__ = e),
            (t.prototype = Object.create(e && e.prototype)),
            (t.prototype.constructor = t),
            (t.prototype.push = function (e, t, n) {
              var a = this
              this.transitionTo(
                e,
                function (e) {
                  ;(a.stack = a.stack.slice(0, a.index + 1).concat(e)), a.index++, t && t(e)
                },
                n
              )
            }),
            (t.prototype.replace = function (e, t, n) {
              var a = this
              this.transitionTo(
                e,
                function (e) {
                  ;(a.stack = a.stack.slice(0, a.index).concat(e)), t && t(e)
                },
                n
              )
            }),
            (t.prototype.go = function (e) {
              var t = this,
                n = this.index + e
              if (!(n < 0 || n >= this.stack.length)) {
                var a = this.stack[n]
                this.confirmTransition(
                  a,
                  function () {
                    var e = t.current
                    ;(t.index = n),
                      t.updateRoute(a),
                      t.router.afterHooks.forEach(function (t) {
                        t && t(a, e)
                      })
                  },
                  function (e) {
                    rp(e, ep.duplicated) && (t.index = n)
                  }
                )
              }
            }),
            (t.prototype.getCurrentLocation = function () {
              var e = this.stack[this.stack.length - 1]
              return e ? e.fullPath : '/'
            }),
            (t.prototype.ensureURL = function () {}),
            t
          )
        })(dp),
        kp = function (e) {
          void 0 === e && (e = {}),
            (this.app = null),
            (this.apps = []),
            (this.options = e),
            (this.beforeHooks = []),
            (this.resolveHooks = []),
            (this.afterHooks = []),
            (this.matcher = Pu(e.routes || [], this))
          var t = e.mode || 'hash'
          switch (
            ((this.fallback = 'history' === t && !Yu && !1 !== e.fallback),
            this.fallback && (t = 'hash'),
            Ru || (t = 'abstract'),
            (this.mode = t),
            t)
          ) {
            case 'history':
              this.history = new fp(this, e.base)
              break
            case 'hash':
              this.history = new hp(this, e.base, this.fallback)
              break
            case 'abstract':
              this.history = new _p(this, e.base)
          }
        },
        Ap = { currentRoute: { configurable: !0 } }
      ;(kp.prototype.match = function (e, t, n) {
        return this.matcher.match(e, t, n)
      }),
        (Ap.currentRoute.get = function () {
          return this.history && this.history.current
        }),
        (kp.prototype.init = function (e) {
          var t = this
          if (
            (this.apps.push(e),
            e.$once('hook:destroyed', function () {
              var n = t.apps.indexOf(e)
              n > -1 && t.apps.splice(n, 1), t.app === e && (t.app = t.apps[0] || null), t.app || t.history.teardown()
            }),
            !this.app)
          ) {
            this.app = e
            var n = this.history
            if (n instanceof fp || n instanceof hp) {
              var a = function (e) {
                n.setupListeners(),
                  (function (e) {
                    var a = n.current,
                      i = t.options.scrollBehavior
                    Yu && i && 'fullPath' in e && Wu(t, e, a, !1)
                  })(e)
              }
              n.transitionTo(n.getCurrentLocation(), a, a)
            }
            n.listen(function (e) {
              t.apps.forEach(function (t) {
                t._route = e
              })
            })
          }
        }),
        (kp.prototype.beforeEach = function (e) {
          return Cp(this.beforeHooks, e)
        }),
        (kp.prototype.beforeResolve = function (e) {
          return Cp(this.resolveHooks, e)
        }),
        (kp.prototype.afterEach = function (e) {
          return Cp(this.afterHooks, e)
        }),
        (kp.prototype.onReady = function (e, t) {
          this.history.onReady(e, t)
        }),
        (kp.prototype.onError = function (e) {
          this.history.onError(e)
        }),
        (kp.prototype.push = function (e, t, n) {
          var a = this
          if (!t && !n && 'undefined' != typeof Promise)
            return new Promise(function (t, n) {
              a.history.push(e, t, n)
            })
          this.history.push(e, t, n)
        }),
        (kp.prototype.replace = function (e, t, n) {
          var a = this
          if (!t && !n && 'undefined' != typeof Promise)
            return new Promise(function (t, n) {
              a.history.replace(e, t, n)
            })
          this.history.replace(e, t, n)
        }),
        (kp.prototype.go = function (e) {
          this.history.go(e)
        }),
        (kp.prototype.back = function () {
          this.go(-1)
        }),
        (kp.prototype.forward = function () {
          this.go(1)
        }),
        (kp.prototype.getMatchedComponents = function (e) {
          var t = e ? (e.matched ? e : this.resolve(e).route) : this.currentRoute
          return t
            ? [].concat.apply(
                [],
                t.matched.map(function (e) {
                  return Object.keys(e.components).map(function (t) {
                    return e.components[t]
                  })
                })
              )
            : []
        }),
        (kp.prototype.resolve = function (e, t, n) {
          var a = ku(e, (t = t || this.history.current), n, this),
            i = this.match(a, t),
            r = i.redirectedFrom || i.fullPath,
            s = (function (e, t, n) {
              var a = 'hash' === n ? '#' + t : t
              return e ? ru(e + '/' + a) : a
            })(this.history.base, r, this.mode)
          return { location: a, route: i, href: s, normalizedTo: a, resolved: i }
        }),
        (kp.prototype.getRoutes = function () {
          return this.matcher.getRoutes()
        }),
        (kp.prototype.addRoute = function (e, t) {
          this.matcher.addRoute(e, t),
            this.history.current !== Xo && this.history.transitionTo(this.history.getCurrentLocation())
        }),
        (kp.prototype.addRoutes = function (e) {
          this.matcher.addRoutes(e),
            this.history.current !== Xo && this.history.transitionTo(this.history.getCurrentLocation())
        }),
        Object.defineProperties(kp.prototype, Ap)
      var Mp = kp
      function Cp(e, t) {
        return (
          e.push(t),
          function () {
            var n = e.indexOf(t)
            n > -1 && e.splice(n, 1)
          }
        )
      }
      ;(kp.install = function e(t) {
        if (!e.installed || Au !== t) {
          ;(e.installed = !0), (Au = t)
          var n = function (e) {
              return void 0 !== e
            },
            a = function (e, t) {
              var a = e.$options._parentVnode
              n(a) && n((a = a.data)) && n((a = a.registerRouteInstance)) && a(e, t)
            }
          t.mixin({
            beforeCreate: function () {
              n(this.$options.router)
                ? ((this._routerRoot = this),
                  (this._router = this.$options.router),
                  this._router.init(this),
                  t.util.defineReactive(this, '_route', this._router.history.current))
                : (this._routerRoot = (this.$parent && this.$parent._routerRoot) || this),
                a(this, this)
            },
            destroyed: function () {
              a(this)
            },
          }),
            Object.defineProperty(t.prototype, '$router', {
              get: function () {
                return this._routerRoot._router
              },
            }),
            Object.defineProperty(t.prototype, '$route', {
              get: function () {
                return this._routerRoot._route
              },
            }),
            t.component('RouterView', nu),
            t.component('RouterLink', Cu)
          var i = t.config.optionMergeStrategies
          i.beforeRouteEnter = i.beforeRouteLeave = i.beforeRouteUpdate = i.created
        }
      }),
        (kp.version = '3.6.5'),
        (kp.isNavigationFailure = rp),
        (kp.NavigationFailureType = ep),
        (kp.START_LOCATION = Xo),
        Ru && window.Vue && window.Vue.use(kp)
      var Sp = function () {
        var e = this._self._c
        return e('div', { staticClass: 'min-h-screen bg-gray-100 px-4 pt-6' }, [e('router-view')], 1)
      }
      function xp(e, t, n, a, i, r, s, o) {
        var u,
          p = 'function' == typeof e ? e.options : e
        if (
          (t && ((p.render = t), (p.staticRenderFns = n), (p._compiled = !0)),
          a && (p.functional = !0),
          r && (p._scopeId = 'data-v-' + r),
          s
            ? ((u = function (e) {
                ;(e =
                  e ||
                  (this.$vnode && this.$vnode.ssrContext) ||
                  (this.parent && this.parent.$vnode && this.parent.$vnode.ssrContext)) ||
                  'undefined' == typeof __VUE_SSR_CONTEXT__ ||
                  (e = __VUE_SSR_CONTEXT__),
                  i && i.call(this, e),
                  e && e._registeredComponents && e._registeredComponents.add(s)
              }),
              (p._ssrRegister = u))
            : i &&
              (u = o
                ? function () {
                    i.call(this, (p.functional ? this.parent : this).$root.$options.shadowRoot)
                  }
                : i),
          u)
        )
          if (p.functional) {
            p._injectStyles = u
            var l = p.render
            p.render = function (e, t) {
              return u.call(t), l(e, t)
            }
          } else {
            var d = p.beforeCreate
            p.beforeCreate = d ? [].concat(d, u) : [u]
          }
        return { exports: e, options: p }
      }
      ;(Sp._withStripped = !0), n(884)
      const Rp = xp({}, Sp, [], !1, null, null, null).exports
      var Op = function () {
        var e = this,
          t = e._self._c
        return t(
          'div',
          { staticClass: 'w-full space-y-10 md:max-w-screen-sm lg:max-w-screen-md mx-auto' },
          [
            t('HeaderBar'),
            e._v(' '),
            t(
              'div',
              { staticClass: 'pb-32' },
              [
                t('div', { staticClass: 'space-y-4' }, [
                  t('span', { staticClass: 'text-lg' }, [e._v('\n        ' + e._s(e.json.source) + '\n      ')]),
                  e._v(' '),
                  t('h1', { staticClass: 'text-xl' }, [e._v('\n        ' + e._s(e.json.name) + '\n      ')]),
                  e._v(' '),
                  t('h2', { staticClass: 'text-lg' }, [e._v('\n        ' + e._s(e.json.title) + '\n      ')]),
                  e._v(' '),
                  t('h2', { staticClass: 'text-lg' }, [e._v('\n        ' + e._s(e.json.author) + '\n      ')]),
                  e._v(' '),
                  t('p', [e._v(e._s(e.json.notice))]),
                  e._v(' '),
                  t('p', [e._v(e._s(e.json.details))]),
                ]),
                e._v(' '),
                t(
                  'div',
                  { staticClass: 'mt-8' },
                  [
                    e.json.hasOwnProperty('constructor')
                      ? t('Member', { attrs: { json: e.json.constructor } })
                      : e._e(),
                  ],
                  1
                ),
                e._v(' '),
                t(
                  'div',
                  { staticClass: 'mt-8' },
                  [e.json.receive ? t('Member', { attrs: { json: e.json.receive } }) : e._e()],
                  1
                ),
                e._v(' '),
                t(
                  'div',
                  { staticClass: 'mt-8' },
                  [e.json.fallback ? t('Member', { attrs: { json: e.json.fallback } }) : e._e()],
                  1
                ),
                e._v(' '),
                e.json.events ? t('MemberSet', { attrs: { title: 'Events', json: e.json.events } }) : e._e(),
                e._v(' '),
                e.json.stateVariables
                  ? t('MemberSet', { attrs: { title: 'State Variables', json: e.json.stateVariables } })
                  : e._e(),
                e._v(' '),
                e.json.methods ? t('MemberSet', { attrs: { title: 'Methods', json: e.json.methods } }) : e._e(),
              ],
              1
            ),
            e._v(' '),
            t('FooterBar'),
          ],
          1
        )
      }
      Op._withStripped = !0
      var Ep = function () {
        var e = this,
          t = e._self._c
        return t(
          'div',
          { staticClass: 'bg-gray-100 fixed bottom-0 right-0 w-full border-t border-dashed border-gray-300' },
          [
            t('div', { staticClass: 'w-full text-center py-2 md:max-w-screen-sm lg:max-w-screen-md mx-auto' }, [
              t(
                'button',
                {
                  staticClass: 'py-1 px-2 text-gray-500',
                  on: {
                    click: function (t) {
                      return e.openLink(e.repository)
                    },
                  },
                },
                [e._v('\n      built with ' + e._s(e.name) + '\n    ')]
              ),
            ]),
          ]
        )
      }
      Ep._withStripped = !0
      const Ip = JSON.parse('{"UU":"hardhat-docgen","Jk":"https://github.com/ItsNickBarry/hardhat-docgen"}'),
        Pp = xp(
          {
            data: function () {
              return { repository: Ip.Jk, name: Ip.UU }
            },
            methods: {
              openLink(e) {
                window.open(e, '_blank')
              },
            },
          },
          Ep,
          [],
          !1,
          null,
          null,
          null
        ).exports
      var Bp = function () {
        var e = this._self._c
        return e(
          'div',
          { staticClass: 'w-full border-b border-dashed py-2 border-gray-300' },
          [
            e('router-link', { staticClass: 'py-2 text-gray-500', attrs: { to: '/' } }, [
              this._v('\n    <- Go back\n  '),
            ]),
          ],
          1
        )
      }
      Bp._withStripped = !0
      const Up = xp({}, Bp, [], !1, null, null, null).exports
      var $p = function () {
        var e = this,
          t = e._self._c
        return t('div', { staticClass: 'border-2 border-gray-400 border-dashed w-full p-2' }, [
          t('h3', { staticClass: 'text-lg pb-2 mb-2 border-b-2 border-gray-400 border-dashed' }, [
            e._v('\n    ' + e._s(e.name) + ' ' + e._s(e.keywords) + ' ' + e._s(e.inputSignature) + '\n  '),
          ]),
          e._v(' '),
          t(
            'div',
            { staticClass: 'space-y-3' },
            [
              t('p', [e._v(e._s(e.json.notice))]),
              e._v(' '),
              t('p', [e._v(e._s(e.json.details))]),
              e._v(' '),
              t('MemberSection', { attrs: { name: 'Parameters', items: e.inputs } }),
              e._v(' '),
              t('MemberSection', { attrs: { name: 'Return Values', items: e.outputs } }),
            ],
            1
          ),
        ])
      }
      $p._withStripped = !0
      var Dp = function () {
        var e = this,
          t = e._self._c
        return e.items.length > 0
          ? t(
              'ul',
              [
                t('h4', { staticClass: 'text-lg' }, [e._v('\n    ' + e._s(e.name) + '\n  ')]),
                e._v(' '),
                e._l(e.items, function (n, a) {
                  return t('li', { key: a }, [
                    t('span', { staticClass: 'bg-gray-300' }, [e._v(e._s(n.type))]),
                    e._v(' '),
                    t('b', [e._v(e._s(n.name || `_${a}`))]),
                    n.desc ? t('span', [e._v(': '), t('i', [e._v(e._s(n.desc))])]) : e._e(),
                  ])
                }),
              ],
              2
            )
          : e._e()
      }
      Dp._withStripped = !0
      const Vp = {
          components: {
            MemberSection: xp(
              { props: { name: { type: String, default: '' }, items: { type: Array, default: () => new Array() } } },
              Dp,
              [],
              !1,
              null,
              null,
              null
            ).exports,
          },
          props: { json: { type: Object, default: () => new Object() } },
          computed: {
            name: function () {
              return this.json.name || this.json.type
            },
            keywords: function () {
              let e = []
              return (
                this.json.stateMutability && e.push(this.json.stateMutability),
                'true' === this.json.anonymous && e.push('anonymous'),
                e.join(' ')
              )
            },
            params: function () {
              return this.json.params || {}
            },
            returns: function () {
              return this.json.returns || {}
            },
            inputs: function () {
              return (this.json.inputs || []).map((e) => ({ ...e, desc: this.params[e.name] }))
            },
            inputSignature: function () {
              return `(${this.inputs.map((e) => e.type).join(',')})`
            },
            outputs: function () {
              return (this.json.outputs || []).map((e, t) => ({ ...e, desc: this.returns[e.name || `_${t}`] }))
            },
            outputSignature: function () {
              return `(${this.outputs.map((e) => e.type).join(',')})`
            },
          },
        },
        Np = xp(Vp, $p, [], !1, null, null, null).exports
      var jp = function () {
        var e = this,
          t = e._self._c
        return t(
          'div',
          { staticClass: 'w-full mt-8' },
          [
            t('h2', { staticClass: 'text-lg' }, [e._v(e._s(e.title))]),
            e._v(' '),
            e._l(Object.keys(e.json), function (n) {
              return t('Member', { key: n, staticClass: 'mt-3', attrs: { json: e.json[n] } })
            }),
          ],
          2
        )
      }
      jp._withStripped = !0
      var Fp = xp(
        {
          components: { Member: Np },
          props: { title: { type: String, default: '' }, json: { type: Object, default: () => new Object() } },
        },
        jp,
        [],
        !1,
        null,
        null,
        null
      )
      const Wp = xp(
        {
          components: { Member: Np, MemberSet: Fp.exports, HeaderBar: Up, FooterBar: Pp },
          props: { json: { type: Object, default: () => new Object() } },
        },
        Op,
        [],
        !1,
        null,
        null,
        null
      ).exports
      var Lp = function () {
        var e = this,
          t = e._self._c
        return t(
          'div',
          { staticClass: 'w-full space-y-10 md:max-w-screen-sm lg:max-w-screen-md mx-auto pb-32' },
          [
            t('Branch', { attrs: { json: e.trees, name: 'Sources:' } }),
            e._v(' '),
            t('FooterBar', { staticClass: 'mt-20' }),
          ],
          1
        )
      }
      Lp._withStripped = !0
      var qp = function () {
        var e = this,
          t = e._self._c
        return t('div', [
          e._v('\n  ' + e._s(e.name) + '\n  '),
          Array.isArray(e.json)
            ? t(
                'div',
                { staticClass: 'pl-5' },
                e._l(e.json, function (n, a) {
                  return t(
                    'div',
                    { key: a },
                    [
                      t('router-link', { attrs: { to: `${n.source}:${n.name}` } }, [
                        e._v('\n        ' + e._s(n.name) + '\n      '),
                      ]),
                    ],
                    1
                  )
                }),
                0
              )
            : t(
                'div',
                { staticClass: 'pl-5' },
                e._l(Object.keys(e.json), function (n) {
                  return t('div', { key: n }, [t('Branch', { attrs: { json: e.json[n], name: n } })], 1)
                }),
                0
              ),
        ])
      }
      qp._withStripped = !0
      var zp = xp(
        {
          name: 'Branch',
          props: {
            name: { type: String, default: null },
            json: { type: [Object, Array], default: () => new Object() },
          },
        },
        qp,
        [],
        !1,
        null,
        null,
        null
      )
      const Hp = xp(
        {
          components: { Branch: zp.exports, FooterBar: Pp },
          props: { json: { type: Object, default: () => new Object() } },
          computed: {
            trees: function () {
              let e = {}
              for (let t in this.json)
                t.replace('/', '//')
                  .split(/\/(?=[^\/])/)
                  .reduce(
                    function (e, n) {
                      if (!n.includes(':')) return (e[n] = e[n] || {}), e[n]
                      {
                        let [a] = n.split(':')
                        ;(e[a] = e[a] || []), e[a].push(this.json[t])
                      }
                    }.bind(this),
                    e
                  )
              return e
            },
          },
        },
        Lp,
        [],
        !1,
        null,
        null,
        null
      ).exports
      Jn.use(Mp)
      const Gp = {
        'contracts/interfaces/I1inchSpotAgg.sol:I1inchSpotAgg': {
          source: 'contracts/interfaces/I1inchSpotAgg.sol',
          name: 'I1inchSpotAgg',
          methods: {
            'getRate(address,address,bool)': {
              inputs: [
                { internalType: 'contract IERC20', name: 'srcToken', type: 'address' },
                { internalType: 'contract IERC20', name: 'dstToken', type: 'address' },
                { internalType: 'bool', name: 'useWrappers', type: 'bool' },
              ],
              name: 'getRate',
              outputs: [{ internalType: 'uint256', name: 'weightedRate', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getRateToEth(address,bool)': {
              inputs: [
                { internalType: 'contract IERC20', name: 'srcToken', type: 'address' },
                { internalType: 'bool', name: 'useWrappers', type: 'bool' },
              ],
              name: 'getRateToEth',
              outputs: [{ internalType: 'uint256', name: 'weightedRate', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Agent.sol:IBaluniV1Agent': {
          source: 'contracts/interfaces/IBaluniV1Agent.sol',
          name: 'IBaluniV1Agent',
          methods: {
            'execute((address,uint256,bytes)[],address[])': {
              inputs: [
                {
                  components: [
                    { internalType: 'address', name: 'to', type: 'address' },
                    { internalType: 'uint256', name: 'value', type: 'uint256' },
                    { internalType: 'bytes', name: 'data', type: 'bytes' },
                  ],
                  internalType: 'struct IBaluniV1Agent.Call[]',
                  name: 'calls',
                  type: 'tuple[]',
                },
                { internalType: 'address[]', name: 'tokensReturn', type: 'address[]' },
              ],
              name: 'execute',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1AgentFactory.sol:IBaluniV1AgentFactory': {
          source: 'contracts/interfaces/IBaluniV1AgentFactory.sol',
          name: 'IBaluniV1AgentFactory',
          methods: {
            'getAgentAddress(address)': {
              inputs: [{ internalType: 'address', name: 'user', type: 'address' }],
              name: 'getAgentAddress',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getOrCreateAgent(address)': {
              inputs: [{ internalType: 'address', name: 'user', type: 'address' }],
              name: 'getOrCreateAgent',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Oracle.sol:IBaluniV1Oracle': {
          source: 'contracts/interfaces/IBaluniV1Oracle.sol',
          name: 'IBaluniV1Oracle',
          methods: {
            'convert(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convert',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'convertScaled(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertScaled',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Pool.sol:IBaluniV1Pool': {
          source: 'contracts/interfaces/IBaluniV1Pool.sol',
          name: 'IBaluniV1Pool',
          title: 'IBaluniV1Pool',
          details: 'Interface for the BaluniV1Pool contract',
          events: {
            'Deposit(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'Deposit',
              type: 'event',
            },
            'RebalancePerformed(address,address[])': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'address[]', name: 'assets', type: 'address[]' },
              ],
              name: 'RebalancePerformed',
              type: 'event',
            },
            'Swap(address,address,address,uint256,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'address', name: 'fromToken', type: 'address' },
                { indexed: !1, internalType: 'address', name: 'toToken', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amountIn', type: 'uint256' },
                { indexed: !1, internalType: 'uint256', name: 'amountOut', type: 'uint256' },
              ],
              name: 'Swap',
              type: 'event',
            },
            'WeightsRebalanced(address,uint256[])': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256[]', name: 'amountsToAdd', type: 'uint256[]' },
              ],
              name: 'WeightsRebalanced',
              type: 'event',
            },
            'Withdraw(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'Withdraw',
              type: 'event',
            },
          },
          methods: {
            'assetLiquidity(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'assetIndex', type: 'uint256' }],
              name: 'assetLiquidity',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'deposit(address,uint256[],uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256[]', name: 'amounts', type: 'uint256[]' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'deposit',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'getAmountOut(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'getAmountOut',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getAssetReserve(address)': {
              inputs: [{ internalType: 'address', name: 'asset', type: 'address' }],
              name: 'getAssetReserve',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getAssets()': {
              inputs: [],
              name: 'getAssets',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getDeviationForToken(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getDeviationForToken',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getDeviations()': {
              inputs: [],
              name: 'getDeviations',
              outputs: [
                { internalType: 'bool[]', name: 'directions', type: 'bool[]' },
                { internalType: 'uint256[]', name: 'deviations', type: 'uint256[]' },
              ],
              stateMutability: 'view',
              type: 'function',
            },
            'getReserves()': {
              inputs: [],
              name: 'getReserves',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getSlippage(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getSlippage',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getSlippageParams()': {
              inputs: [],
              name: 'getSlippageParams',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getTokenWeight(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getTokenWeight',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getWeights()': {
              inputs: [],
              name: 'getWeights',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'initialize(address[],uint256[],uint256,address)': {
              inputs: [
                { internalType: 'address[]', name: '_assets', type: 'address[]' },
                { internalType: 'uint256[]', name: '_weights', type: 'uint256[]' },
                { internalType: 'uint256', name: '_trigger', type: 'uint256' },
                { internalType: 'address', name: '_registry', type: 'address' },
              ],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'isRebalanceNeeded()': {
              inputs: [],
              name: 'isRebalanceNeeded',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
            },
            'liquidity()': {
              inputs: [],
              name: 'liquidity',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'quotePotentialSwap(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'quotePotentialSwap',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'rebalance()': {
              inputs: [],
              name: 'rebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'rebalanceAndDeposit(address)': {
              inputs: [{ internalType: 'address', name: 'receiver', type: 'address' }],
              name: 'rebalanceAndDeposit',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'swap(address,address,uint256,uint256,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'uint256', name: 'minAmount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swap',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'fee', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'totalValuation()': {
              inputs: [],
              name: 'totalValuation',
              outputs: [
                { internalType: 'uint256', name: 'totalVal', type: 'uint256' },
                { internalType: 'uint256[]', name: 'valuations', type: 'uint256[]' },
              ],
              stateMutability: 'view',
              type: 'function',
            },
            'unitPrice()': {
              inputs: [],
              name: 'unitPrice',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'withdraw(uint256,address,uint256)': {
              inputs: [
                { internalType: 'uint256', name: 'share', type: 'uint256' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'withdraw',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1PoolPeriphery.sol:IBaluniV1PoolPeriphery': {
          source: 'contracts/interfaces/IBaluniV1PoolPeriphery.sol',
          name: 'IBaluniV1PoolPeriphery',
          title: 'IBaluniV1PoolPeriphery',
          details: 'Interface for the BaluniV1PoolPeriphery contract',
          methods: {
            'batchSwap(address[],address[],uint256[],address[])': {
              inputs: [
                { internalType: 'address[]', name: 'fromTokens', type: 'address[]' },
                { internalType: 'address[]', name: 'toTokens', type: 'address[]' },
                { internalType: 'uint256[]', name: 'amounts', type: 'uint256[]' },
                { internalType: 'address[]', name: 'receivers', type: 'address[]' },
              ],
              name: 'batchSwap',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'getAmountOut(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'getAmountOut',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getPoolsContainingToken(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getPoolsContainingToken',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getVersion()': {
              inputs: [],
              name: 'getVersion',
              outputs: [{ internalType: 'uint64', name: '', type: 'uint64' }],
              stateMutability: 'view',
              type: 'function',
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'swapTokenForToken(address,address,uint256,uint256,address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'minAmount', type: 'uint256' },
                { internalType: 'address', name: 'from', type: 'address' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swapTokenForToken',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'haircut', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'swapTokensForTokens(address[],address[],uint256,uint256,address,uint256)': {
              inputs: [
                { internalType: 'address[]', name: 'tokenPath', type: 'address[]' },
                { internalType: 'address[]', name: 'poolPath', type: 'address[]' },
                { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'minimumToAmount', type: 'uint256' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swapTokensForTokens',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'haircut', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1PoolRegistry.sol:IBaluniV1PoolRegistry': {
          source: 'contracts/interfaces/IBaluniV1PoolRegistry.sol',
          name: 'IBaluniV1PoolRegistry',
          methods: {
            'getAllPools()': {
              inputs: [],
              name: 'getAllPools',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getPoolByAssets(address,address)': {
              inputs: [
                { internalType: 'address', name: 'asset1', type: 'address' },
                { internalType: 'address', name: 'asset2', type: 'address' },
              ],
              name: 'getPoolByAssets',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getPoolsByAsset(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getPoolsByAsset',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'poolExist(address)': {
              inputs: [{ internalType: 'address', name: '_pool', type: 'address' }],
              name: 'poolExist',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Rebalancer.sol:IBaluniV1Rebalancer': {
          source: 'contracts/interfaces/IBaluniV1Rebalancer.sol',
          name: 'IBaluniV1Rebalancer',
          methods: {
            'checkRebalance(uint256[],address[],uint256[],uint256,address,address)': {
              inputs: [
                { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'baseAsset', type: 'address' },
              ],
              name: 'checkRebalance',
              outputs: [
                {
                  components: [
                    { internalType: 'uint256', name: 'length', type: 'uint256' },
                    { internalType: 'uint256', name: 'totalValue', type: 'uint256' },
                    { internalType: 'uint256', name: 'finalUsdBalance', type: 'uint256' },
                    { internalType: 'uint256', name: 'overweightVaultsLength', type: 'uint256' },
                    { internalType: 'uint256', name: 'underweightVaultsLength', type: 'uint256' },
                    { internalType: 'uint256', name: 'totalActiveWeight', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                    { internalType: 'uint256[]', name: 'overweightVaults', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'overweightAmounts', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'underweightVaults', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'underweightAmounts', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                  ],
                  internalType: 'struct IBaluniV1Rebalancer.RebalanceVars',
                  name: '',
                  type: 'tuple',
                },
              ],
              stateMutability: 'view',
              type: 'function',
            },
            'convert(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convert',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'rebalance(uint256[],address[],uint256[],uint256,address,address,address)': {
              inputs: [
                { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'address', name: 'baseAsset', type: 'address' },
              ],
              name: 'rebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Registry.sol:IBaluniV1Registry': {
          source: 'contracts/interfaces/IBaluniV1Registry.sol',
          name: 'IBaluniV1Registry',
          title: 'IBaluniV1Registry',
          details: 'Interface for the BaluniV1Registry contract.',
          methods: {
            'get1inchSpotAgg()': {
              inputs: [],
              name: 'get1inchSpotAgg',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBPS_BASE()': {
              inputs: [],
              name: 'getBPS_BASE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBPS_FEE()': {
              inputs: [],
              name: 'getBPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniAgentFactory()': {
              inputs: [],
              name: 'getBaluniAgentFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniOracle()': {
              inputs: [],
              name: 'getBaluniOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniPoolPeriphery()': {
              inputs: [],
              name: 'getBaluniPoolPeriphery',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniPoolRegistry()': {
              inputs: [],
              name: 'getBaluniPoolRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRebalancer()': {
              inputs: [],
              name: 'getBaluniRebalancer',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRegistry()': {
              inputs: [],
              name: 'getBaluniRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRouter()': {
              inputs: [],
              name: 'getBaluniRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniSwapper()': {
              inputs: [],
              name: 'getBaluniSwapper',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getMAX_BPS_FEE()': {
              inputs: [],
              name: 'getMAX_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getStaticOracle()': {
              inputs: [],
              name: 'getStaticOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getTreasury()': {
              inputs: [],
              name: 'getTreasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUSDC()': {
              inputs: [],
              name: 'getUSDC',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUniswapFactory()': {
              inputs: [],
              name: 'getUniswapFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUniswapRouter()': {
              inputs: [],
              name: 'getUniswapRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getWNATIVE()': {
              inputs: [],
              name: 'getWNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'set1inchSpotAgg(address)': {
              inputs: [{ internalType: 'address', name: '__1inchSpotAgg', type: 'address' }],
              name: 'set1inchSpotAgg',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBPS_FEE(uint256)': {
              inputs: [{ internalType: 'uint256', name: '__BPS_FEE', type: 'uint256' }],
              name: 'setBPS_FEE',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniAgentFactory(address)': {
              inputs: [{ internalType: 'address', name: '_baluniAgentFactory', type: 'address' }],
              name: 'setBaluniAgentFactory',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniOracle(address)': {
              inputs: [{ internalType: 'address', name: '_baluniOracle', type: 'address' }],
              name: 'setBaluniOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniPoolPeriphery(address)': {
              inputs: [{ internalType: 'address', name: '_baluniPoolPeriphery', type: 'address' }],
              name: 'setBaluniPoolPeriphery',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniPoolRegistry(address)': {
              inputs: [{ internalType: 'address', name: '_baluniPoolRegistry', type: 'address' }],
              name: 'setBaluniPoolRegistry',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRebalancer(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRebalancer', type: 'address' }],
              name: 'setBaluniRebalancer',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRegistry(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRegistry', type: 'address' }],
              name: 'setBaluniRegistry',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRouter(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRouter', type: 'address' }],
              name: 'setBaluniRouter',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniSwapper(address)': {
              inputs: [{ internalType: 'address', name: '_baluniSwapper', type: 'address' }],
              name: 'setBaluniSwapper',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setStaticOracle(address)': {
              inputs: [{ internalType: 'address', name: '_staticOracle', type: 'address' }],
              name: 'setStaticOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setTreasury(address)': {
              inputs: [{ internalType: 'address', name: '_treasury', type: 'address' }],
              name: 'setTreasury',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUSDC(address)': {
              inputs: [{ internalType: 'address', name: '_USDC', type: 'address' }],
              name: 'setUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUniswapFactory(address)': {
              inputs: [{ internalType: 'address', name: '_uniswapFactory', type: 'address' }],
              name: 'setUniswapFactory',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUniswapRouter(address)': {
              inputs: [{ internalType: 'address', name: '_uniswapRouter', type: 'address' }],
              name: 'setUniswapRouter',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setWNATIVE(address)': {
              inputs: [{ internalType: 'address', name: '_WNATIVE', type: 'address' }],
              name: 'setWNATIVE',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Router.sol:IBaluniV1Router': {
          source: 'contracts/interfaces/IBaluniV1Router.sol',
          name: 'IBaluniV1Router',
          methods: {
            'USDC()': {
              inputs: [],
              name: 'USDC',
              outputs: [{ internalType: 'contract IERC20', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WNATIVE()': {
              inputs: [],
              name: 'WNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_BPS_BASE()': {
              inputs: [],
              name: '_BPS_BASE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_BPS_FEE()': {
              inputs: [],
              name: '_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_MAX_BPS_FEE()': {
              inputs: [],
              name: '_MAX_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'agentFactory()': {
              inputs: [],
              name: 'agentFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniFactory()': {
              inputs: [],
              name: 'baluniFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniPeriphery()': {
              inputs: [],
              name: 'baluniPeriphery',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'burnERC20(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'burnAmount', type: 'uint256' }],
              name: 'burnERC20',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'burnUSDC(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'burnAmount', type: 'uint256' }],
              name: 'burnUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'calculateTokenShare(uint256,uint256,uint256,uint256)': {
              inputs: [
                { internalType: 'uint256', name: 'totalBaluni', type: 'uint256' },
                { internalType: 'uint256', name: 'totalERC20Balance', type: 'uint256' },
                { internalType: 'uint256', name: 'baluniAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'tokenDecimals', type: 'uint256' },
              ],
              name: 'calculateTokenShare',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'pure',
              type: 'function',
            },
            'callRebalance(address[],uint256[],address,address,uint256,address)': {
              inputs: [
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: 'baseAsset', type: 'address' },
              ],
              name: 'callRebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'changeAgentFactory(address)': {
              inputs: [{ internalType: 'address', name: '_agentFactory', type: 'address' }],
              name: 'changeAgentFactory',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'changeBpsFee(uint256)': {
              inputs: [{ internalType: 'uint256', name: '_newFee', type: 'uint256' }],
              name: 'changeBpsFee',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'changeMarketOracle(address)': {
              inputs: [{ internalType: 'address', name: '_marketOracle', type: 'address' }],
              name: 'changeMarketOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'changeRebalancer(address)': {
              inputs: [{ internalType: 'address', name: '_newRebalancer', type: 'address' }],
              name: 'changeRebalancer',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'changeTreasury(address)': {
              inputs: [{ internalType: 'address', name: '_newTreasury', type: 'address' }],
              name: 'changeTreasury',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'execute((address,uint256,bytes)[],address[])': {
              inputs: [
                {
                  components: [
                    { internalType: 'address', name: 'to', type: 'address' },
                    { internalType: 'uint256', name: 'value', type: 'uint256' },
                    { internalType: 'bytes', name: 'data', type: 'bytes' },
                  ],
                  internalType: 'struct IBaluniV1Agent.Call[]',
                  name: 'calls',
                  type: 'tuple[]',
                },
                { internalType: 'address[]', name: 'tokensReturn', type: 'address[]' },
              ],
              name: 'execute',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'fetchMarketPrices()': {
              inputs: [],
              name: 'fetchMarketPrices',
              outputs: [
                { internalType: 'uint256', name: '', type: 'uint256' },
                { internalType: 'uint256', name: '', type: 'uint256' },
              ],
              stateMutability: 'view',
              type: 'function',
            },
            'getAgentAddress(address)': {
              inputs: [{ internalType: 'address', name: '_user', type: 'address' }],
              name: 'getAgentAddress',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getTokens()': {
              inputs: [],
              name: 'getTokens',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUSDCShareValue(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'amount', type: 'uint256' }],
              name: 'getUSDCShareValue',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getVersion()': {
              inputs: [],
              name: 'getVersion',
              outputs: [{ internalType: 'uint64', name: '', type: 'uint64' }],
              stateMutability: 'view',
              type: 'function',
            },
            'initialize(address,address,address,address,address,address)': {
              inputs: [
                { internalType: 'address', name: '_usdc', type: 'address' },
                { internalType: 'address', name: '_wnative', type: 'address' },
                { internalType: 'address', name: '_1inchSpotAgg', type: 'address' },
                { internalType: 'address', name: '_uniRouter', type: 'address' },
                { internalType: 'address', name: '_uniFactory', type: 'address' },
                { internalType: 'address', name: '_rebalancer', type: 'address' },
              ],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'initializeMarketOracle(address)': {
              inputs: [{ internalType: 'address', name: '_marketOracle', type: 'address' }],
              name: 'initializeMarketOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'liquidate(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'liquidate',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'liquidateAll()': {
              inputs: [],
              name: 'liquidateAll',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'marketOracle()': {
              inputs: [],
              name: 'marketOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'mintWithUSDC(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'balAmountToMint', type: 'uint256' }],
              name: 'mintWithUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'oracle()': {
              inputs: [],
              name: 'oracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'rebalancer()': {
              inputs: [],
              name: 'rebalancer',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,address,address,address,address,address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_usdc', type: 'address' },
                { internalType: 'address', name: '_wnative', type: 'address' },
                { internalType: 'address', name: '_1inchSpotAgg', type: 'address' },
                { internalType: 'address', name: '_uniRouter', type: 'address' },
                { internalType: 'address', name: '_uniFactory', type: 'address' },
                { internalType: 'address', name: '_rebalancer', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'requiredUSDCtoMint(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'balAmountToMint', type: 'uint256' }],
              name: 'requiredUSDCtoMint',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'tokenValuation(uint256,address)': {
              inputs: [
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'token', type: 'address' },
              ],
              name: 'tokenValuation',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'totalValuation()': {
              inputs: [],
              name: 'totalValuation',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'treasury()': {
              inputs: [],
              name: 'treasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'uniswapFactory()': {
              inputs: [],
              name: 'uniswapFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'uniswapRouter()': {
              inputs: [],
              name: 'uniswapRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'unitPrice()': {
              inputs: [],
              name: 'unitPrice',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IBaluniV1Swapper.sol:IBaluniV1Swapper': {
          source: 'contracts/interfaces/IBaluniV1Swapper.sol',
          name: 'IBaluniV1Swapper',
          methods: {
            'multiHopSwap(address,address,address,uint256,address)': {
              inputs: [
                { internalType: 'address', name: 'token0', type: 'address' },
                { internalType: 'address', name: 'token1', type: 'address' },
                { internalType: 'address', name: 'token2', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
              ],
              name: 'multiHopSwap',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'singleSwap(address,address,uint256,address)': {
              inputs: [
                { internalType: 'address', name: 'token0', type: 'address' },
                { internalType: 'address', name: 'token1', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
              ],
              name: 'singleSwap',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
            },
          },
        },
        'contracts/interfaces/IStaticOracle.sol:IStaticOracle': {
          source: 'contracts/interfaces/IStaticOracle.sol',
          name: 'IStaticOracle',
          title: 'Uniswap V3 Static Oracle',
          notice: 'Oracle contract for calculating price quoting against Uniswap V3',
          methods: {
            'CARDINALITY_PER_MINUTE()': {
              inputs: [],
              name: 'CARDINALITY_PER_MINUTE',
              outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
              stateMutability: 'view',
              type: 'function',
              details: 'This value is assigned during deployment and cannot be changed',
              returns: { _0: 'Number of observation that are needed per minute' },
              notice:
                'Returns how many observations are needed per minute in Uniswap V3 oracles, on the deployed chain',
            },
            'UNISWAP_V3_FACTORY()': {
              inputs: [],
              name: 'UNISWAP_V3_FACTORY',
              outputs: [{ internalType: 'contract IUniswapV3Factory', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'This value is assigned during deployment and cannot be changed',
              returns: { _0: 'The address of the Uniswap V3 factory' },
              notice: 'Returns the address of the Uniswap V3 factory',
            },
            'addNewFeeTier(uint24)': {
              inputs: [{ internalType: 'uint24', name: 'feeTier', type: 'uint24' }],
              name: 'addNewFeeTier',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Will revert if the given tier is invalid, or already supported',
              params: { feeTier: 'The new fee tier to add' },
              notice: 'Adds support for a new fee tier',
            },
            'getAllPoolsForPair(address,address)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
              ],
              name: 'getAllPoolsForPair',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'The pair can be provided in tokenA/tokenB or tokenB/tokenA order',
              returns: { _0: 'All existing pools for the given pair' },
              notice: 'Returns all existing pools for the given pair',
            },
            'isPairSupported(address,address)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
              ],
              name: 'isPairSupported',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
              details: 'The pair can be provided in tokenA/tokenB or tokenB/tokenA order',
              returns: { _0: 'Whether the given pair can be supported by the oracle' },
              notice: 'Returns whether a specific pair can be supported by the oracle',
            },
            'prepareAllAvailablePoolsWithCardinality(address,address,uint16)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
                { internalType: 'uint16', name: 'cardinality', type: 'uint16' },
              ],
              name: 'prepareAllAvailablePoolsWithCardinality',
              outputs: [{ internalType: 'address[]', name: 'preparedPools', type: 'address[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Will revert if there are no pools available for the pair and period combination',
              params: {
                cardinality: 'The cardinality that will be guaranteed when quoting',
                tokenA: "One of the pair's tokens",
                tokenB: "The other of the pair's tokens",
              },
              returns: { preparedPools: 'The pools that were prepared' },
              notice:
                'Will increase observations for all existing pools for the given pair, so they start accruing information for twap calculations',
            },
            'prepareAllAvailablePoolsWithTimePeriod(address,address,uint32)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'prepareAllAvailablePoolsWithTimePeriod',
              outputs: [{ internalType: 'address[]', name: 'preparedPools', type: 'address[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Will revert if there are no pools available for the pair and period combination',
              params: {
                period: 'The period that will be guaranteed when quoting',
                tokenA: "One of the pair's tokens",
                tokenB: "The other of the pair's tokens",
              },
              returns: { preparedPools: 'The pools that were prepared' },
              notice:
                'Will initialize all existing pools for the given pair, so that they can be queried with the given period in the future',
            },
            'prepareSpecificFeeTiersWithCardinality(address,address,uint24[],uint16)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
                { internalType: 'uint24[]', name: 'feeTiers', type: 'uint24[]' },
                { internalType: 'uint16', name: 'cardinality', type: 'uint16' },
              ],
              name: 'prepareSpecificFeeTiersWithCardinality',
              outputs: [{ internalType: 'address[]', name: 'preparedPools', type: 'address[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Will revert if the pair does not have a pool for a given fee tier',
              params: {
                cardinality: 'The cardinality that will be guaranteed when quoting',
                feeTiers: "The fee tiers to consider when searching for the pair's pools",
                tokenA: "One of the pair's tokens",
                tokenB: "The other of the pair's tokens",
              },
              returns: { preparedPools: 'The pools that were prepared' },
              notice:
                "Will increase the pair's pools with the specified fee tiers observations, so they start accruing information for twap calculations",
            },
            'prepareSpecificFeeTiersWithTimePeriod(address,address,uint24[],uint32)': {
              inputs: [
                { internalType: 'address', name: 'tokenA', type: 'address' },
                { internalType: 'address', name: 'tokenB', type: 'address' },
                { internalType: 'uint24[]', name: 'feeTiers', type: 'uint24[]' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'prepareSpecificFeeTiersWithTimePeriod',
              outputs: [{ internalType: 'address[]', name: 'preparedPools', type: 'address[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Will revert if the pair does not have a pool for a given fee tier',
              params: {
                feeTiers: "The fee tiers to consider when searching for the pair's pools",
                period: 'The period that will be guaranteed when quoting',
                tokenA: "One of the pair's tokens",
                tokenB: "The other of the pair's tokens",
              },
              returns: { preparedPools: 'The pools that were prepared' },
              notice:
                "Will initialize the pair's pools with the specified fee tiers, so that they can be queried with the given period in the future",
            },
            'prepareSpecificPoolsWithCardinality(address[],uint16)': {
              inputs: [
                { internalType: 'address[]', name: 'pools', type: 'address[]' },
                { internalType: 'uint16', name: 'cardinality', type: 'uint16' },
              ],
              name: 'prepareSpecificPoolsWithCardinality',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              params: {
                cardinality: 'The cardinality that will be guaranteed when quoting',
                pools: 'The pools to initialize',
              },
              notice:
                'Will increase all given pools observations, so they start accruing information for twap calculations',
            },
            'prepareSpecificPoolsWithTimePeriod(address[],uint32)': {
              inputs: [
                { internalType: 'address[]', name: 'pools', type: 'address[]' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'prepareSpecificPoolsWithTimePeriod',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              params: { period: 'The period that will be guaranteed when quoting', pools: 'The pools to initialize' },
              notice:
                'Will initialize all given pools, so that they can be queried with the given period in the future',
            },
            'quoteAllAvailablePoolsWithTimePeriod(uint128,address,address,uint32)': {
              inputs: [
                { internalType: 'uint128', name: 'baseAmount', type: 'uint128' },
                { internalType: 'address', name: 'baseToken', type: 'address' },
                { internalType: 'address', name: 'quoteToken', type: 'address' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'quoteAllAvailablePoolsWithTimePeriod',
              outputs: [
                { internalType: 'uint256', name: 'quoteAmount', type: 'uint256' },
                { internalType: 'address[]', name: 'queriedPools', type: 'address[]' },
              ],
              stateMutability: 'view',
              type: 'function',
              details:
                'If some pools are not configured correctly for the given period, then they will be ignoredWill revert if there are no pools available/configured for the pair and period combination',
              params: {
                baseAmount: 'Amount of token to be converted',
                baseToken: 'Address of an ERC20 token contract used as the baseAmount denomination',
                period: 'Number of seconds from which to calculate the TWAP',
                quoteToken: 'Address of an ERC20 token contract used as the quoteAmount denomination',
              },
              returns: {
                queriedPools: 'The pools that were queried to calculate the quote',
                quoteAmount: 'Amount of quoteToken received for baseAmount of baseToken',
              },
              notice: "Returns a quote, based on the given tokens and amount, by querying all of the pair's pools",
            },
            'quoteSpecificFeeTiersWithTimePeriod(uint128,address,address,uint24[],uint32)': {
              inputs: [
                { internalType: 'uint128', name: 'baseAmount', type: 'uint128' },
                { internalType: 'address', name: 'baseToken', type: 'address' },
                { internalType: 'address', name: 'quoteToken', type: 'address' },
                { internalType: 'uint24[]', name: 'feeTiers', type: 'uint24[]' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'quoteSpecificFeeTiersWithTimePeriod',
              outputs: [
                { internalType: 'uint256', name: 'quoteAmount', type: 'uint256' },
                { internalType: 'address[]', name: 'queriedPools', type: 'address[]' },
              ],
              stateMutability: 'view',
              type: 'function',
              details:
                'Will revert if the pair does not have a pool for one of the given fee tiers, or if one of the pools is not prepared/configured correctly for the given period',
              params: {
                baseAmount: 'Amount of token to be converted',
                baseToken: 'Address of an ERC20 token contract used as the baseAmount denomination',
                feeTiers: 'The fee tiers to consider when calculating the quote',
                period: 'Number of seconds from which to calculate the TWAP',
                quoteToken: 'Address of an ERC20 token contract used as the quoteAmount denomination',
              },
              returns: {
                queriedPools: 'The pools that were queried to calculate the quote',
                quoteAmount: 'Amount of quoteToken received for baseAmount of baseToken',
              },
              notice: 'Returns a quote, based on the given tokens and amount, by querying only the specified fee tiers',
            },
            'quoteSpecificPoolsWithTimePeriod(uint128,address,address,address[],uint32)': {
              inputs: [
                { internalType: 'uint128', name: 'baseAmount', type: 'uint128' },
                { internalType: 'address', name: 'baseToken', type: 'address' },
                { internalType: 'address', name: 'quoteToken', type: 'address' },
                { internalType: 'address[]', name: 'pools', type: 'address[]' },
                { internalType: 'uint32', name: 'period', type: 'uint32' },
              ],
              name: 'quoteSpecificPoolsWithTimePeriod',
              outputs: [{ internalType: 'uint256', name: 'quoteAmount', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Will revert if one of the pools is not prepared/configured correctly for the given period',
              params: {
                baseAmount: 'Amount of token to be converted',
                baseToken: 'Address of an ERC20 token contract used as the baseAmount denomination',
                period: 'Number of seconds from which to calculate the TWAP',
                pools: 'The pools to consider when calculating the quote',
                quoteToken: 'Address of an ERC20 token contract used as the quoteAmount denomination',
              },
              returns: { quoteAmount: 'Amount of quoteToken received for baseAmount of baseToken' },
              notice: 'Returns a quote, based on the given tokens and amount, by querying only the specified pools',
            },
            'supportedFeeTiers()': {
              inputs: [],
              name: 'supportedFeeTiers',
              outputs: [{ internalType: 'uint24[]', name: '', type: 'uint24[]' }],
              stateMutability: 'view',
              type: 'function',
              returns: { _0: 'The supported fee tiers' },
              notice: 'Returns all supported fee tiers',
            },
          },
        },
        'contracts/libs/AddressUpgradeable.sol:AddressUpgradeable': {
          source: 'contracts/libs/AddressUpgradeable.sol',
          name: 'AddressUpgradeable',
          details: 'Collection of functions related to the address type',
        },
        'contracts/libs/ClonesUpgradeable.sol:ClonesUpgradeable': {
          source: 'contracts/libs/ClonesUpgradeable.sol',
          name: 'ClonesUpgradeable',
          details:
            'https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for deploying minimal proxy contracts, also known as "clones". > To simply and cheaply clone contract functionality in an immutable way, this standard specifies > a minimal bytecode implementation that delegates all calls to a known, fixed address. The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2` (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the deterministic method. _Available since v3.4._',
        },
        'contracts/libs/DSMath.sol:DSMath': {
          source: 'contracts/libs/DSMath.sol',
          name: 'DSMath',
          methods: {
            'RAY()': {
              inputs: [],
              name: 'RAY',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WAD()': {
              inputs: [],
              name: 'WAD',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/libs/EnumerableSetUpgradeable.sol:EnumerableSetUpgradeable': {
          source: 'contracts/libs/EnumerableSetUpgradeable.sol',
          name: 'EnumerableSetUpgradeable',
          details:
            'Library for managing https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive types. Sets have the following properties: - Elements are added, removed, and checked for existence in constant time (O(1)). - Elements are enumerated in O(n). No guarantees are made on the ordering. ``` contract Example {     // Add the library methods     using EnumerableSet for EnumerableSet.AddressSet;     // Declare a set state variable     EnumerableSet.AddressSet private mySet; } ``` As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`) and `uint256` (`UintSet`) are supported. [WARNING] ====  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet. ====',
        },
        'contracts/managers/BaluniV1Rebalancer.sol:BaluniV1Rebalancer': {
          source: 'contracts/managers/BaluniV1Rebalancer.sol',
          name: 'BaluniV1Rebalancer',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'checkRebalance(uint256[],address[],uint256[],uint256,address,address)': {
              inputs: [
                { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'baseAsset', type: 'address' },
              ],
              name: 'checkRebalance',
              outputs: [
                {
                  components: [
                    { internalType: 'uint256', name: 'length', type: 'uint256' },
                    { internalType: 'uint256', name: 'totalValue', type: 'uint256' },
                    { internalType: 'uint256', name: 'finalUsdBalance', type: 'uint256' },
                    { internalType: 'uint256', name: 'overweightVaultsLength', type: 'uint256' },
                    { internalType: 'uint256', name: 'underweightVaultsLength', type: 'uint256' },
                    { internalType: 'uint256', name: 'totalActiveWeight', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                    { internalType: 'uint256[]', name: 'overweightVaults', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'overweightAmounts', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'underweightVaults', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'underweightAmounts', type: 'uint256[]' },
                    { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                  ],
                  internalType: 'struct BaluniV1Rebalancer.RebalanceVars',
                  name: '',
                  type: 'tuple',
                },
              ],
              stateMutability: 'view',
              type: 'function',
              details: 'Checks if a rebalance is needed based on the given parameters.',
              params: {
                assets: 'An array of token addresses.',
                balances: 'An array of token balances.',
                baseAsset: 'The address of the base asset.',
                limit: 'The maximum allowed difference between the current and target weights.',
                sender: 'The address of the caller.',
                weights: 'An array of token weights.',
              },
              returns: { _0: 'A struct containing the rebalance variables.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'rebalance(uint256[],address[],uint256[],uint256,address,address,address)': {
              inputs: [
                { internalType: 'uint256[]', name: 'balances', type: 'uint256[]' },
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'address', name: 'baseAsset', type: 'address' },
              ],
              name: 'rebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Rebalances the portfolio by buying and selling assets based on their weights.',
              params: {
                assets: 'An array of asset addresses.',
                balances: 'An array of current asset balances.',
                baseAsset: 'The base asset used for rebalancing.',
                limit: 'The maximum amount of assets to be rebalanced.',
                receiver: 'The address to which the assets will be transferred.',
                sender: 'The address from which the assets will be transferred.',
                weights: 'An array of asset weights.',
              },
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/managers/BaluniV1Swapper.sol:BaluniV1Swapper': {
          source: 'contracts/managers/BaluniV1Swapper.sol',
          name: 'BaluniV1Swapper',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'multiHopSwap(address,address,address,uint256,address)': {
              inputs: [
                { internalType: 'address', name: 'token0', type: 'address' },
                { internalType: 'address', name: 'token1', type: 'address' },
                { internalType: 'address', name: 'token2', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
              ],
              name: 'multiHopSwap',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Executes a multi-hop swap between three tokens using Uniswap.',
              params: {
                amount: 'The amount of token0 to be swapped.',
                receiver: 'The address that will receive the swapped tokens.',
                token0: 'The address of the token to be swapped.',
                token1: 'The address of the intermediate token to be used for the swap.',
                token2: 'The address of the final token to be received.',
              },
              returns: {
                amountOut:
                  "The amount of token2 received from the swap. The function requires that the caller has a sufficient balance of token0 and that the amount to be swapped is greater than 0. Also, the caller must have approved this contract to spend the amount of token0. The function transfers the amount of token0 to be swapped from the caller to this contract, then performs the swap using Uniswap. The swapped tokens are sent to the receiver's address. The function returns the amount of token2 received from the swap.",
              },
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'singleSwap(address,address,uint256,address)': {
              inputs: [
                { internalType: 'address', name: 'token0', type: 'address' },
                { internalType: 'address', name: 'token1', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
              ],
              name: 'singleSwap',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Executes a single swap between two tokens using Uniswap.',
              params: {
                amount: 'The amount of token0 to be swapped.',
                receiver: 'The address that will receive the swapped tokens.',
                token0: 'The address of the token to be swapped.',
                token1: 'The address of the token to be received.',
              },
              returns: {
                amountOut:
                  "The amount of token1 received from the swap. The function requires that the caller has a sufficient balance of token0 and that the amount to be swapped is greater than 0. Also, the caller must have approved this contract to spend the amount of token0. The function transfers the amount of token0 to be swapped from the caller to this contract, then performs the swap using Uniswap. The swapped tokens are sent to the receiver's address. The function returns the amount of token1 received from the swap.",
              },
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/mock/MockOracle.sol:MockOracle': {
          source: 'contracts/mock/MockOracle.sol',
          name: 'MockOracle',
          constructor: {
            inputs: [
              { internalType: 'address', name: 'usdt', type: 'address' },
              { internalType: 'address', name: '_usdc', type: 'address' },
              { internalType: 'address', name: '_wmatic', type: 'address' },
              { internalType: 'address', name: 'weth', type: 'address' },
              { internalType: 'address', name: 'wbtc', type: 'address' },
            ],
            stateMutability: 'nonpayable',
            type: 'constructor',
          },
          methods: {
            'USDC()': {
              inputs: [],
              name: 'USDC',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_USDT_RATE()': {
              inputs: [],
              name: 'USDC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WBTC_RATE()': {
              inputs: [],
              name: 'USDC_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WETH_RATE()': {
              inputs: [],
              name: 'USDC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'USDC_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_USDC_RATE()': {
              inputs: [],
              name: 'USDT_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WBTC_RATE()': {
              inputs: [],
              name: 'USDT_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WETH_RATE()': {
              inputs: [],
              name: 'USDT_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'USDT_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_USDC_RATE()': {
              inputs: [],
              name: 'WBTC_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_USDT_RATE()': {
              inputs: [],
              name: 'WBTC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_WETH_RATE()': {
              inputs: [],
              name: 'WBTC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'WBTC_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_USDC_RATE()': {
              inputs: [],
              name: 'WETH_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_USDT_RATE()': {
              inputs: [],
              name: 'WETH_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_WBTC_RATE()': {
              inputs: [],
              name: 'WETH_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'WETH_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_USDC_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_USDT_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_WBTC_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_WETH_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WNATIVE()': {
              inputs: [],
              name: 'WNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'convert(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convert',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Converts an amount of tokens from one token to another based on the current exchange rate.',
              params: {
                amount: 'The amount of tokens to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'The converted amount of tokens.' },
            },
            'convertScaled(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertScaled',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Converts the given amount of tokens from one token to another using the 1inch exchange rate.',
              params: {
                amount: 'The amount of tokens to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'The converted amount of tokens.' },
            },
            'rates(address,address)': {
              inputs: [
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'address', name: '', type: 'address' },
              ],
              name: 'rates',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'treasury()': {
              inputs: [],
              name: 'treasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/mock/MockRebalancer.sol:MockRebalancer': {
          source: 'contracts/mock/MockRebalancer.sol',
          name: 'MockRebalancer',
          constructor: {
            inputs: [
              { internalType: 'address', name: 'usdt', type: 'address' },
              { internalType: 'address', name: '_usdc', type: 'address' },
              { internalType: 'address', name: '_wmatic', type: 'address' },
              { internalType: 'address', name: 'weth', type: 'address' },
              { internalType: 'address', name: 'wbtc', type: 'address' },
            ],
            stateMutability: 'nonpayable',
            type: 'constructor',
          },
          methods: {
            'USDC()': {
              inputs: [],
              name: 'USDC',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_USDT_RATE()': {
              inputs: [],
              name: 'USDC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WBTC_RATE()': {
              inputs: [],
              name: 'USDC_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WETH_RATE()': {
              inputs: [],
              name: 'USDC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'USDC_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_USDC_RATE()': {
              inputs: [],
              name: 'USDT_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WBTC_RATE()': {
              inputs: [],
              name: 'USDT_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WETH_RATE()': {
              inputs: [],
              name: 'USDT_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDT_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'USDT_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_USDC_RATE()': {
              inputs: [],
              name: 'WBTC_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_USDT_RATE()': {
              inputs: [],
              name: 'WBTC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_WETH_RATE()': {
              inputs: [],
              name: 'WBTC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WBTC_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'WBTC_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_USDC_RATE()': {
              inputs: [],
              name: 'WETH_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_USDT_RATE()': {
              inputs: [],
              name: 'WETH_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_WBTC_RATE()': {
              inputs: [],
              name: 'WETH_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WETH_TO_WMATIC_RATE()': {
              inputs: [],
              name: 'WETH_TO_WMATIC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_USDC_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_USDC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_USDT_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_USDT_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_WBTC_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_WBTC_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WMATIC_TO_WETH_RATE()': {
              inputs: [],
              name: 'WMATIC_TO_WETH_RATE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WNATIVE()': {
              inputs: [],
              name: 'WNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'checkRebalance(address[],uint256[],uint256[])': {
              inputs: [
                { internalType: 'address[]', name: '', type: 'address[]' },
                { internalType: 'uint256[]', name: '', type: 'uint256[]' },
                { internalType: 'uint256[]', name: '', type: 'uint256[]' },
              ],
              name: 'checkRebalance',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRouter()': {
              inputs: [],
              name: 'getBaluniRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getRate(address,address,bool)': {
              inputs: [
                { internalType: 'contract IERC20', name: 'fromToken', type: 'address' },
                { internalType: 'contract IERC20', name: 'toToken', type: 'address' },
                { internalType: 'bool', name: '', type: 'bool' },
              ],
              name: 'getRate',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getRateToEth(address,bool)': {
              inputs: [
                { internalType: 'contract IERC20', name: 'fromToken', type: 'address' },
                { internalType: 'bool', name: '', type: 'bool' },
              ],
              name: 'getRateToEth',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getTreasury()': {
              inputs: [],
              name: 'getTreasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'rates(address,address)': {
              inputs: [
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'address', name: '', type: 'address' },
              ],
              name: 'rates',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'rebalance(address[],uint256[],address,address,uint256)': {
              inputs: [
                { internalType: 'address[]', name: '', type: 'address[]' },
                { internalType: 'uint256[]', name: '', type: 'uint256[]' },
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'uint256', name: '', type: 'uint256' },
              ],
              name: 'rebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setRate(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'rate', type: 'uint256' },
              ],
              name: 'setRate',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setTreasury(address)': {
              inputs: [{ internalType: 'address', name: '_treasury', type: 'address' }],
              name: 'setTreasury',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'treasury()': {
              inputs: [],
              name: 'treasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/mock/MockSwapRouter.sol:MockSwapRouter': {
          source: 'contracts/mock/MockSwapRouter.sol',
          name: 'MockSwapRouter',
          methods: {
            'exactInput((address[],address,uint256,uint256,uint256))': {
              inputs: [
                {
                  components: [
                    { internalType: 'address[]', name: 'path', type: 'address[]' },
                    { internalType: 'address', name: 'recipient', type: 'address' },
                    { internalType: 'uint256', name: 'deadline', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountIn', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountOutMinimum', type: 'uint256' },
                  ],
                  internalType: 'struct MockSwapRouter.ExactInputParams',
                  name: 'params',
                  type: 'tuple',
                },
              ],
              name: 'exactInput',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'payable',
              type: 'function',
            },
            'exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160))': {
              inputs: [
                {
                  components: [
                    { internalType: 'address', name: 'tokenIn', type: 'address' },
                    { internalType: 'address', name: 'tokenOut', type: 'address' },
                    { internalType: 'uint24', name: 'fee', type: 'uint24' },
                    { internalType: 'address', name: 'recipient', type: 'address' },
                    { internalType: 'uint256', name: 'deadline', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountIn', type: 'uint256' },
                    { internalType: 'uint256', name: 'amountOutMinimum', type: 'uint256' },
                    { internalType: 'uint160', name: 'sqrtPriceLimitX96', type: 'uint160' },
                  ],
                  internalType: 'struct MockSwapRouter.ExactInputSingleParams',
                  name: 'params',
                  type: 'tuple',
                },
              ],
              name: 'exactInputSingle',
              outputs: [{ internalType: 'uint256', name: 'amountOut', type: 'uint256' }],
              stateMutability: 'payable',
              type: 'function',
            },
          },
        },
        'contracts/mock/MockToken.sol:MockToken': {
          source: 'contracts/mock/MockToken.sol',
          name: 'MockToken',
          constructor: {
            inputs: [
              { internalType: 'string', name: 'name', type: 'string' },
              { internalType: 'string', name: 'symbol', type: 'string' },
              { internalType: 'uint8', name: 'decimals_', type: 'uint8' },
            ],
            stateMutability: 'nonpayable',
            type: 'constructor',
          },
          events: {
            'Approval(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'owner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'spender', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Approval',
              type: 'event',
              details:
                'Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.',
            },
            'Transfer(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'from', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'to', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Transfer',
              type: 'event',
              details:
                'Emitted when `value` tokens are moved from one account (`from`) to another (`to`). Note that `value` may be zero.',
            },
          },
          methods: {
            'allowance(address,address)': {
              inputs: [
                { internalType: 'address', name: 'owner', type: 'address' },
                { internalType: 'address', name: 'spender', type: 'address' },
              ],
              name: 'allowance',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-allowance}.',
            },
            'approve(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'spender', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'approve',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-approve}. NOTE: If `value` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.',
            },
            'balanceOf(address)': {
              inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
              name: 'balanceOf',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-balanceOf}.',
            },
            'decimals()': {
              inputs: [],
              name: 'decimals',
              outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the default value returned by this function, unless it's overridden. NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.",
            },
            'mint(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'mint',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'name()': {
              inputs: [],
              name: 'name',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the name of the token.',
            },
            'symbol()': {
              inputs: [],
              name: 'symbol',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the symbol of the token, usually a shorter version of the name.',
            },
            'totalSupply()': {
              inputs: [],
              name: 'totalSupply',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-totalSupply}.',
            },
            'transfer(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transfer',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `value`.',
            },
            'transferFrom(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'from', type: 'address' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transferFrom',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                "See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `value`. - the caller must have allowance for ``from``'s tokens of at least `value`.",
            },
          },
        },
        'contracts/oracles/BaluniV1Oracle.sol:BaluniV1Oracle': {
          source: 'contracts/oracles/BaluniV1Oracle.sol',
          name: 'BaluniV1Oracle',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'convert(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convert',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details:
                'Converts the specified amount of `fromToken` to `toToken` using the available oracle. If the conversion fails with the static oracle, it falls back to the aggregator oracle.',
              params: {
                amount: 'The amount of `fromToken` to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'The converted valuation of `amount` in `toToken`.' },
            },
            'convertScaled(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertScaled',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details:
                'Converts the specified amount of `fromToken` to `toToken` using the available oracle. If the conversion fails with the static oracle, it falls back to the aggregator oracle. This function is externally callable.',
              params: {
                amount: 'The amount of `fromToken` to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'The converted valuation of `amount` in `toToken`.' },
            },
            'convertScaledWithAgg(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertScaledWithAgg',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details:
                'Converts the specified amount of `fromToken` to `toToken` using the 1inch aggregator and scales the result.',
              params: {
                amount: 'The amount of `fromToken` to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: ' The scaled converted valuation of `amount` in `toToken`.' },
            },
            'convertScaledWithStaticOracle(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertScaledWithStaticOracle',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Converts the given amount of tokens from one token to another using a static oracle.',
              params: {
                amount: 'The amount of tokens to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'of the converted tokens.' },
            },
            'convertWithAgg(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertWithAgg',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Converts the specified amount of `fromToken` to `toToken` using the 1inch aggregator.',
              params: {
                amount: 'The amount of `fromToken` to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'The converted valuation of `amount` in `toToken`.' },
            },
            'convertWithStaticOracle(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'convertWithStaticOracle',
              outputs: [{ internalType: 'uint256', name: 'valuation', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Converts the specified amount of `fromToken` to `toToken` using the static oracle.',
              params: {
                amount: 'The amount of `fromToken` to convert.',
                fromToken: 'The address of the token to convert from.',
                toToken: 'The address of the token to convert to.',
              },
              returns: { valuation: 'of the converted amount.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/orchestators/BaluniV1Agent.sol:BaluniV1Agent': {
          source: 'contracts/orchestators/BaluniV1Agent.sol',
          name: 'BaluniV1Agent',
          title: 'BaluniV1Agent',
          details: 'This contract represents the BaluniV1Agent contract.',
          constructor: {
            inputs: [{ internalType: 'address', name: '_factory', type: 'address' }],
            stateMutability: 'nonpayable',
            type: 'constructor',
          },
          methods: {
            'execute((address,uint256,bytes)[],address[])': {
              inputs: [
                {
                  components: [
                    { internalType: 'address', name: 'to', type: 'address' },
                    { internalType: 'uint256', name: 'value', type: 'uint256' },
                    { internalType: 'bytes', name: 'data', type: 'bytes' },
                  ],
                  internalType: 'struct BaluniV1Agent.Call[]',
                  name: 'calls',
                  type: 'tuple[]',
                },
                { internalType: 'address[]', name: 'tokensReturn', type: 'address[]' },
              ],
              name: 'execute',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Executes a batch of calls and performs token operations.',
              params: {
                calls: 'An array of Call structs representing the calls to be executed.',
                tokensReturn: 'An array of token addresses to return after the batch call.',
              },
              notice: 'Only the router contract is allowed to execute this function.',
            },
            'getFactory()': {
              inputs: [],
              name: 'getFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the factory contract.',
              returns: { _0: 'The address of the factory contract.' },
            },
            'getRouter()': {
              inputs: [],
              name: 'getRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the router contract.',
              returns: { _0: 'The address of the router contract.' },
            },
            'initialize(address,address)': {
              inputs: [
                { internalType: 'address', name: '_owner', type: 'address' },
                { internalType: 'address', name: '_registry', type: 'address' },
              ],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Initializes the contract with the specified owner and router addresses.',
              params: {
                _owner: 'The address of the contract owner.',
                _registry: 'The address of the registry contract.',
              },
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/orchestators/BaluniV1AgentFactory.sol:BaluniV1AgentFactory': {
          source: 'contracts/orchestators/BaluniV1AgentFactory.sol',
          name: 'BaluniV1AgentFactory',
          events: {
            'AgentCreated(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !1, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'address', name: 'agent', type: 'address' },
              ],
              name: 'AgentCreated',
              type: 'event',
            },
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'changeImplementation()': {
              inputs: [],
              name: 'changeImplementation',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Changes the implementation of the BaluniV1Agent contract. Only the contract owner can call this function. Creates a new instance of BaluniV1Agent and updates the implementation address.',
            },
            'getAgentAddress(address)': {
              inputs: [{ internalType: 'address', name: 'user', type: 'address' }],
              name: 'getAgentAddress',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the address of the BaluniV1Agent contract associated with a user.',
              params: { user: 'The address of the user.' },
              returns: { _0: 'The address of the BaluniV1Agent contract associated with the user.' },
            },
            'getOrCreateAgent(address)': {
              inputs: [{ internalType: 'address', name: 'user', type: 'address' }],
              name: 'getOrCreateAgent',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                "Returns the address of an existing agent for the given user, or creates a new agent if one doesn't exist.",
              params: { user: 'The address of the user.' },
              returns: { _0: 'The address of the agent.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Initializes the contract by calling the initializers of the parent contracts.',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
            'userAgents(address)': {
              inputs: [{ internalType: 'address', name: '', type: 'address' }],
              name: 'userAgents',
              outputs: [{ internalType: 'contract BaluniV1Agent', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
          },
        },
        'contracts/orchestators/BaluniV1Router.sol:BaluniV1Router': {
          source: 'contracts/orchestators/BaluniV1Router.sol',
          name: 'BaluniV1Router',
          events: {
            'Approval(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'owner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'spender', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Approval',
              type: 'event',
              details:
                'Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.',
            },
            'Burn(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !1, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Burn',
              type: 'event',
            },
            'Execute(address,(address,uint256,bytes)[],address[])': {
              anonymous: !1,
              inputs: [
                { indexed: !1, internalType: 'address', name: 'user', type: 'address' },
                {
                  components: [
                    { internalType: 'address', name: 'to', type: 'address' },
                    { internalType: 'uint256', name: 'value', type: 'uint256' },
                    { internalType: 'bytes', name: 'data', type: 'bytes' },
                  ],
                  indexed: !1,
                  internalType: 'struct IBaluniV1Agent.Call[]',
                  name: 'calls',
                  type: 'tuple[]',
                },
                { indexed: !1, internalType: 'address[]', name: 'tokensReturn', type: 'address[]' },
              ],
              name: 'Execute',
              type: 'event',
            },
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'Log(string,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !1, internalType: 'string', name: 'message', type: 'string' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Log',
              type: 'event',
            },
            'Mint(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !1, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Mint',
              type: 'event',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Transfer(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'from', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'to', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Transfer',
              type: 'event',
              details:
                'Emitted when `value` tokens are moved from one account (`from`) to another (`to`). Note that `value` may be zero.',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'addToken(address)': {
              inputs: [{ internalType: 'address', name: '_token', type: 'address' }],
              name: 'addToken',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Adds a token to the `tokens` set. Can only be called by the contract owner.',
              params: { _token: 'The address of the token to be added.' },
            },
            'allowance(address,address)': {
              inputs: [
                { internalType: 'address', name: 'owner', type: 'address' },
                { internalType: 'address', name: 'spender', type: 'address' },
              ],
              name: 'allowance',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-allowance}.',
            },
            'approve(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'spender', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'approve',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-approve}. NOTE: If `value` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.',
            },
            'balanceOf(address)': {
              inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
              name: 'balanceOf',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-balanceOf}.',
            },
            'baseAsset()': {
              inputs: [],
              name: 'baseAsset',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'burnERC20(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'burnAmount', type: 'uint256' }],
              name: 'burnERC20',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: "Burns a specified amount of BALUNI tokens from the caller's balance.",
              params: { burnAmount: 'The amount of BALUNI tokens to burn.' },
              notice:
                "This function requires the caller to have a balance of at least `burnAmount` BAL tokens.The function also checks the USDC balance before burning the tokens.After burning the tokens, the function transfers a proportional share of each ERC20 token held by the contract to the caller.The share is calculated based on the total supply of BAL tokens, the balance of each ERC20 token, and the decimals of each token.Finally, the function emits a `Burn` event with the caller's address and the amount of tokens burned.",
            },
            'burnUSDC(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'burnAmount', type: 'uint256' }],
              name: 'burnUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Burns a specified amount of BAL tokens and performs token swaps on multiple tokens.',
              params: { burnAmount: 'The amount of BAL tokens to burn.' },
            },
            'calculateTokenShare(uint256,uint256,uint256,uint256)': {
              inputs: [
                { internalType: 'uint256', name: 'totalBaluni', type: 'uint256' },
                { internalType: 'uint256', name: 'totalERC20Balance', type: 'uint256' },
                { internalType: 'uint256', name: 'baluniAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'tokenDecimals', type: 'uint256' },
              ],
              name: 'calculateTokenShare',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'pure',
              type: 'function',
              details:
                'Calculates the token share based on the total Baluni supply, total ERC20 balance, Baluni amount, and token decimals.',
              params: {
                baluniAmount: 'The amount of Baluni tokens.',
                tokenDecimals: 'The number of decimals for the ERC20 token.',
                totalBaluni: 'The total supply of Baluni tokens.',
                totalERC20Balance: 'The total balance of the ERC20 token.',
              },
              returns: { _0: 'The calculated token share.' },
            },
            'callRebalance(address[],uint256[],address,address,uint256,address)': {
              inputs: [
                { internalType: 'address[]', name: 'assets', type: 'address[]' },
                { internalType: 'uint256[]', name: 'weights', type: 'uint256[]' },
                { internalType: 'address', name: 'sender', type: 'address' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'uint256', name: 'limit', type: 'uint256' },
                { internalType: 'address', name: '', type: 'address' },
              ],
              name: 'callRebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Calls the `rebalance` function of the `rebalancer` contract.',
              params: {
                assets: 'An array of addresses representing the assets to rebalance.',
                limit: 'The maximum number of assets to rebalance.',
                receiver: 'The address of the receiver.',
                sender: 'The address of the sender.',
                weights: 'An array of uint256 values representing the weights of the assets.',
              },
            },
            'decimals()': {
              inputs: [],
              name: 'decimals',
              outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the default value returned by this function, unless it's overridden. NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.",
            },
            'execute((address,uint256,bytes)[],address[])': {
              inputs: [
                {
                  components: [
                    { internalType: 'address', name: 'to', type: 'address' },
                    { internalType: 'uint256', name: 'value', type: 'uint256' },
                    { internalType: 'bytes', name: 'data', type: 'bytes' },
                  ],
                  internalType: 'struct IBaluniV1Agent.Call[]',
                  name: 'calls',
                  type: 'tuple[]',
                },
                { internalType: 'address[]', name: 'tokensReturn', type: 'address[]' },
              ],
              name: 'execute',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Executes a series of calls to a BaluniV1Agent contract and handles token returns.',
              params: {
                calls: 'An array of IBaluniV1Agent.Call structs representing the calls to be executed.',
                tokensReturn: 'An array of addresses representing the tokens to be returned.',
              },
              notice:
                'This function requires the agentFactory to be set and creates a new agent if necessary.If a token is new and a Uniswap pool exists for it, the token is added to the tokens set.If no Uniswap pool exists for a token, the token balance is transferred back to the caller.',
            },
            'getAgentAddress(address)': {
              inputs: [{ internalType: 'address', name: '_user', type: 'address' }],
              name: 'getAgentAddress',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the agent address associated with a user.',
              params: { _user: "The user's address." },
              returns: { _0: 'The agent address.' },
            },
            'getTokens()': {
              inputs: [],
              name: 'getTokens',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns an array of addresses representing the tokens.',
              returns: { _0: 'An array of addresses representing the tokens.' },
            },
            'getUSDCShareValue(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'amount', type: 'uint256' }],
              name: 'getUSDCShareValue',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Calculates the value of a given amount of Baluni tokens in USDC.',
              params: { amount: 'The amount of Baluni tokens.' },
              returns: { _0: 'The calculated value of the Baluni tokens in USDC.' },
            },
            'getVersion()': {
              inputs: [],
              name: 'getVersion',
              outputs: [{ internalType: 'uint64', name: '', type: 'uint64' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the version of the contract.',
              returns: { _0: 'The version string.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                "Initializes the BaluniV1Router contract. It sets the initial values for various variables and mints 1 ether to the contract's address. It also sets the USDC token address, WNATIVE token address, oracle address, Uniswap router address, and Uniswap factory address. Finally, it adds the USDC token address to the tokens set.",
            },
            'liquidate(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'liquidate',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Liquidates the specified token by swapping it for USDC.',
              params: { token: 'The address of the token to be liquidated.' },
              notice:
                'The contract must have sufficient approval to spend the specified token.If a pool exists for the token and USDC on Uniswap, a direct swap is performed.If no pool exists, a multi-hop swap is performed through the WNATIVE token.If the swap fails, the `burn` function should be called to handle the failed swap.',
            },
            'liquidateAll()': {
              inputs: [],
              name: 'liquidateAll',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Liquidates all tokens in the contract. This function iterates through all the tokens in the contract and calls the `liquidate` function for each token. Can only be called by the contract owner.',
            },
            'mintWithUSDC(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'balAmountToMint', type: 'uint256' }],
              name: 'mintWithUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Mints a specified amount of BALUNI tokens in exchange for USDC.',
              params: { balAmountToMint: 'The amount of BALUNI tokens to mint.' },
            },
            'name()': {
              inputs: [],
              name: 'name',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the name of the token.',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'requiredUSDCtoMint(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'balAmountToMint', type: 'uint256' }],
              name: 'requiredUSDCtoMint',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Calculates the amount of USDC required to mint a given amount of BAL tokens.',
              params: { balAmountToMint: 'The amount of BAL tokens to be minted.' },
              returns: { _0: 'The amount of USDC required to mint the specified amount of BAL tokens.' },
            },
            'resetContract(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'resetContract',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'symbol()': {
              inputs: [],
              name: 'symbol',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the symbol of the token, usually a shorter version of the name.',
            },
            'tokenValuation(uint256,address)': {
              inputs: [
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'address', name: 'token', type: 'address' },
              ],
              name: 'tokenValuation',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Calculates the valuation of a given amount of a specific ERC20 token.',
              params: { amount: 'The amount of the ERC20 token.', token: 'The address of the ERC20 token.' },
              returns: { _0: 'The calculated valuation of the ERC20 token.' },
            },
            'totalSupply()': {
              inputs: [],
              name: 'totalSupply',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-totalSupply}.',
            },
            'totalValuation()': {
              inputs: [],
              name: 'totalValuation',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the total valuation of the Baluni ecosystem.',
              returns: { _0: 'The total valuation of the Baluni ecosystem.' },
            },
            'transfer(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transfer',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `value`.',
            },
            'transferFrom(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'from', type: 'address' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transferFrom',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                "See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `value`. - the caller must have allowance for ``from``'s tokens of at least `value`.",
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'unitPrice()': {
              inputs: [],
              name: 'unitPrice',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the unit price of the token in USDC.',
              returns: { _0: 'The unit price of the token in USDC.' },
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/pools/BaluniV1Pool.sol:BaluniV1Pool': {
          source: 'contracts/pools/BaluniV1Pool.sol',
          name: 'BaluniV1Pool',
          events: {
            'Approval(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'owner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'spender', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Approval',
              type: 'event',
              details:
                'Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.',
            },
            'Deposit(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'Deposit',
              type: 'event',
            },
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Paused(address)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'address', name: 'account', type: 'address' }],
              name: 'Paused',
              type: 'event',
              details: 'Emitted when the pause is triggered by `account`.',
            },
            'RebalancePerformed(address,address[])': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'address[]', name: 'assets', type: 'address[]' },
              ],
              name: 'RebalancePerformed',
              type: 'event',
            },
            'Swap(address,address,address,uint256,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'address', name: 'fromToken', type: 'address' },
                { indexed: !1, internalType: 'address', name: 'toToken', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amountIn', type: 'uint256' },
                { indexed: !1, internalType: 'uint256', name: 'amountOut', type: 'uint256' },
              ],
              name: 'Swap',
              type: 'event',
            },
            'Transfer(address,address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'from', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'to', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'Transfer',
              type: 'event',
              details:
                'Emitted when `value` tokens are moved from one account (`from`) to another (`to`). Note that `value` may be zero.',
            },
            'Unpaused(address)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'address', name: 'account', type: 'address' }],
              name: 'Unpaused',
              type: 'event',
              details: 'Emitted when the pause is lifted by `account`.',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
            'WeightsRebalanced(address,uint256[])': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256[]', name: 'amountsToAdd', type: 'uint256[]' },
              ],
              name: 'WeightsRebalanced',
              type: 'event',
            },
            'Withdraw(address,uint256)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'user', type: 'address' },
                { indexed: !1, internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'Withdraw',
              type: 'event',
            },
          },
          methods: {
            'ONE()': {
              inputs: [],
              name: 'ONE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'allowance(address,address)': {
              inputs: [
                { internalType: 'address', name: 'owner', type: 'address' },
                { internalType: 'address', name: 'spender', type: 'address' },
              ],
              name: 'allowance',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-allowance}.',
            },
            'approve(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'spender', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'approve',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-approve}. NOTE: If `value` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.',
            },
            'assetInfos(uint256)': {
              inputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              name: 'assetInfos',
              outputs: [
                { internalType: 'address', name: 'asset', type: 'address' },
                { internalType: 'uint256', name: 'weight', type: 'uint256' },
                { internalType: 'uint256', name: 'slippage', type: 'uint256' },
                { internalType: 'uint256', name: 'reserve', type: 'uint256' },
              ],
              stateMutability: 'view',
              type: 'function',
            },
            'assetLiquidity(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'assetIndex', type: 'uint256' }],
              name: 'assetLiquidity',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the liquidity of a specific asset in the pool.',
              params: { assetIndex: 'The index of the asset.' },
              returns: { _0: 'The liquidity of the asset.' },
            },
            'balanceOf(address)': {
              inputs: [{ internalType: 'address', name: 'account', type: 'address' }],
              name: 'balanceOf',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-balanceOf}.',
            },
            'baseAsset()': {
              inputs: [],
              name: 'baseAsset',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'calculateAssetShare(uint256)': {
              inputs: [{ internalType: 'uint256', name: 'share', type: 'uint256' }],
              name: 'calculateAssetShare',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Calculates the asset shares based on the provided share amount.',
              params: { share: 'The share amount to calculate the asset shares for.' },
              returns: { _0: 'An array of asset shares corresponding to each asset in the pool.' },
            },
            'decimals()': {
              inputs: [],
              name: 'decimals',
              outputs: [{ internalType: 'uint8', name: '', type: 'uint8' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the default value returned by this function, unless it's overridden. NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.",
            },
            'deposit(address,uint256[],uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256[]', name: 'amounts', type: 'uint256[]' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'deposit',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Mints new tokens and adds them to the specified address.',
              params: { to: 'The address to which the new tokens will be minted.' },
              returns: { _0: 'The amount of tokens minted.' },
            },
            'getAmountOut(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'getAmountOut',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details:
                'Calculates the amount of `toToken` that will be received when swapping `fromToken` for `toToken`.',
              params: {
                amount: 'The amount of `fromToken` being swapped.',
                fromToken: 'The address of the token being swapped from.',
                toToken: 'The address of the token being swapped to.',
              },
              returns: { _0: 'The amount of `toToken` that will be received.' },
            },
            'getAssetReserve(address)': {
              inputs: [{ internalType: 'address', name: 'asset', type: 'address' }],
              name: 'getAssetReserve',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the reserve amount of the specified asset.',
              params: { asset: 'The address of the asset.' },
              returns: { _0: 'The reserve amount of the asset.' },
            },
            'getAssets()': {
              inputs: [],
              name: 'getAssets',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the list of assets in the pool.',
              returns: { _0: 'An array of addresses representing the assets.' },
            },
            'getDeviationForToken(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getDeviationForToken',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the deviation for a token in the pool.',
              params: { token: 'The address of the token.' },
              returns: { _0: 'The deviation for the token.' },
            },
            'getDeviations()': {
              inputs: [],
              name: 'getDeviations',
              outputs: [
                { internalType: 'bool[]', name: 'directions', type: 'bool[]' },
                { internalType: 'uint256[]', name: 'deviations', type: 'uint256[]' },
              ],
              stateMutability: 'view',
              type: 'function',
              details:
                'Returns the deviation between the current weights and target weights of the assets in the pool.',
              returns: {
                directions:
                  'An array of boolean values indicating whether the current weight is higher (true) or lower (false) than the target weight.',
              },
            },
            'getReserves()': {
              inputs: [],
              name: 'getReserves',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns an array of reserves for each asset in the pool.',
              returns: { _0: 'An array of reserves.' },
            },
            'getSlippage(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getSlippage',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Restituisce lo slippage attuale per un dato token.',
              params: { token: 'The address of the token.' },
              returns: { _0: 'Lo slippage attuale per il token.' },
            },
            'getSlippageParams()': {
              inputs: [],
              name: 'getSlippageParams',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns an array of slippage parameters for each token in the pool.',
              returns: { _0: 'An array of slippage parameters.' },
            },
            'getTokenWeight(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getTokenWeight',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the weight of a token in the pool.',
              params: { token: 'The address of the token.' },
              returns: { _0: 'The weight of the token.' },
            },
            'getWeights()': {
              inputs: [],
              name: 'getWeights',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the list of weights associated with the assets in the pool.',
              returns: { _0: 'An array of uint256 values representing the weights.' },
            },
            'initialize(address[],uint256[],uint256,address)': {
              inputs: [
                { internalType: 'address[]', name: '_assets', type: 'address[]' },
                { internalType: 'uint256[]', name: '_weights', type: 'uint256[]' },
                { internalType: 'uint256', name: '_trigger', type: 'uint256' },
                { internalType: 'address', name: '_registry', type: 'address' },
              ],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Initializes the BaluniV1Pool contract.',
              params: {
                _assets: 'The array of asset addresses.',
                _registry: 'The address of the BaluniV1Registry contract.',
                _trigger: 'The trigger value.',
                _weights: 'The array of asset weights.',
              },
            },
            'isRebalanceNeeded()': {
              inputs: [],
              name: 'isRebalanceNeeded',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Checks if rebalancing is needed for the pool.',
              returns: { _0: 'A boolean value indicating whether rebalancing is needed or not.' },
            },
            'k()': {
              inputs: [],
              name: 'k',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'liquidity()': {
              inputs: [],
              name: 'liquidity',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the total liquidity of the pool.',
              returns: { _0: 'The total liquidity of the pool.' },
            },
            'n()': {
              inputs: [],
              name: 'n',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'name()': {
              inputs: [],
              name: 'name',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the name of the token.',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'pause()': {
              inputs: [],
              name: 'pause',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'pause pool, restricting certain operations',
            },
            'paused()': {
              inputs: [],
              name: 'paused',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns true if the contract is paused, and false otherwise.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'quotePotentialSwap(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'quotePotentialSwap',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: "Calcola l'importo effettivo di `toToken` ricevuto tenendo conto dello slippage.",
              params: {
                amount: 'The amount of `fromToken` being swapped.',
                fromToken: 'The address of the token being swapped from.',
                toToken: 'The address of the token being swapped to.',
              },
              returns: { _0: 'The amount of `toToken` received after applying slippage.' },
            },
            'rebalance()': {
              inputs: [],
              name: 'rebalance',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Performs rebalance',
            },
            'rebalanceAndDeposit(address)': {
              inputs: [{ internalType: 'address', name: 'receiver', type: 'address' }],
              name: 'rebalanceAndDeposit',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Rebalances the weights of the pool by calculating the amounts to add for each token, transferring the calculated amounts from the user to the pool, minting the total added liquidity, updating the reserves, and emitting an event to indicate the rebalancing of weights.',
              params: { receiver: 'The address to receive the minted liquidity tokens.' },
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'reserves(address)': {
              inputs: [{ internalType: 'address', name: '', type: 'address' }],
              name: 'reserves',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'swap(address,address,uint256,uint256,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
                { internalType: 'uint256', name: 'minAmount', type: 'uint256' },
                { internalType: 'address', name: 'receiver', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swap',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'fee', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Swaps `amount` of `fromToken` to `toToken` and transfers the received amount to `receiver`. Requirements: - `fromToken` and `toToken` must be different tokens. - `amount` must be greater than zero. - Sufficient liquidity of `toToken` must be available in the contract. Emits a `Swap` event with the details of the swap. Updates the reserves after the swap.',
              params: {
                amount: 'The amount of `fromToken` to swap.',
                fromToken: 'The address of the token to swap from.',
                receiver: 'The address to receive the swapped tokens.',
                toToken: 'The address of the token to swap to.',
              },
              returns: { amountOut: 'The amount of `toToken` received after the swap.' },
            },
            'symbol()': {
              inputs: [],
              name: 'symbol',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the symbol of the token, usually a shorter version of the name.',
            },
            'totalSupply()': {
              inputs: [],
              name: 'totalSupply',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'See {IERC20-totalSupply}.',
            },
            'totalValuation()': {
              inputs: [],
              name: 'totalValuation',
              outputs: [
                { internalType: 'uint256', name: 'totalVal', type: 'uint256' },
                { internalType: 'uint256[]', name: 'valuations', type: 'uint256[]' },
              ],
              stateMutability: 'view',
              type: 'function',
              details:
                'Computes the total valuation of the pool and returns the total valuation and an array of individual valuations.',
              returns: {
                totalVal: 'The total valuation of the pool.',
                valuations: 'An array of individual valuations.',
              },
            },
            'transfer(address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transfer',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `value`.',
            },
            'transferFrom(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'from', type: 'address' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'value', type: 'uint256' },
              ],
              name: 'transferFrom',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                "See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `value`. - the caller must have allowance for ``from``'s tokens of at least `value`.",
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'trigger()': {
              inputs: [],
              name: 'trigger',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'unitPrice()': {
              inputs: [],
              name: 'unitPrice',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the unit price of the pool.',
              returns: { _0: 'The unit price of the pool.' },
            },
            'unpause()': {
              inputs: [],
              name: 'unpause',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'unpause pool, enabling certain operations',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
            'withdraw(uint256,address,uint256)': {
              inputs: [
                { internalType: 'uint256', name: 'share', type: 'uint256' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'withdraw',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Burns the pool tokens and transfers the underlying assets to the specified address.',
              params: { to: 'The address to transfer the underlying assets to.' },
              notice:
                'This function can only be called by the periphery contract.The pool tokens must have a balance greater than 0.The total supply of pool tokens must be greater than 0.The function calculates the amounts of each underlying asset to transfer based on the share of pool tokens being burned.A fee is deducted from the share of pool tokens being burned and transferred to the treasury address.The function checks if the pool has sufficient liquidity before performing any transfers.If any transfer fails, the function reverts the entire operation.After the transfers, the function updates the reserves of the pool.Emits a `Burn` event with the address and share of pool tokens burned.',
            },
          },
        },
        'contracts/pools/BaluniV1PoolPeriphery.sol:BaluniV1PoolPeriphery': {
          source: 'contracts/pools/BaluniV1PoolPeriphery.sol',
          name: 'BaluniV1PoolPeriphery',
          title: 'BaluniV1PoolPeriphery',
          details: 'This contract serves as the periphery contract for interacting with BaluniV1Pool contracts.',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'batchSwap(address[],address[],uint256[],address[])': {
              inputs: [
                { internalType: 'address[]', name: 'fromTokens', type: 'address[]' },
                { internalType: 'address[]', name: 'toTokens', type: 'address[]' },
                { internalType: 'uint256[]', name: 'amounts', type: 'uint256[]' },
                { internalType: 'address[]', name: 'receivers', type: 'address[]' },
              ],
              name: 'batchSwap',
              outputs: [{ internalType: 'uint256[]', name: '', type: 'uint256[]' }],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Performs batch swaps between multiple token pairs.',
              params: {
                amounts: 'An array of amounts representing the amounts to swap.',
                fromTokens: 'An array of addresses representing the tokens to swap from.',
                receivers: 'An array of addresses representing the receivers of the swapped tokens.',
                toTokens: 'An array of addresses representing the tokens to swap to.',
              },
              returns: { _0: 'An array of amounts representing the amounts of tokens received after the swaps.' },
            },
            'getAmountOut(address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'amount', type: 'uint256' },
              ],
              name: 'getAmountOut',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Gets the amount of tokens received after a swap in a BaluniV1Pool.',
              params: {
                amount: 'The amount of tokens to swap.',
                fromToken: 'The address of the token to swap from.',
                toToken: 'The address of the token to swap to.',
              },
              returns: { _0: 'The amount of tokens received after the swap.' },
            },
            'getPoolsContainingToken(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getPoolsContainingToken',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns an array of pool addresses that contain the given token.',
              params: { token: 'The address of the token to search for.' },
              returns: { _0: 'An array of pool addresses.' },
            },
            'getVersion()': {
              inputs: [],
              name: 'getVersion',
              outputs: [{ internalType: 'uint64', name: '', type: 'uint64' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the version of the contract.',
              returns: { _0: 'The version string.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_registry', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'poolsReserves(address,address)': {
              inputs: [
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'address', name: '', type: 'address' },
              ],
              name: 'poolsReserves',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'quotePotentialSwaps(address[],address[],uint256)': {
              inputs: [
                { internalType: 'address[]', name: 'tokenPath', type: 'address[]' },
                { internalType: 'address[]', name: 'poolPath', type: 'address[]' },
                { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
              ],
              name: 'quotePotentialSwaps',
              outputs: [
                { internalType: 'uint256', name: 'potentialOutcome', type: 'uint256' },
                { internalType: 'uint256', name: 'haircut', type: 'uint256' },
              ],
              stateMutability: 'view',
              type: 'function',
              details: 'To be used by frontend',
              params: {
                fromAmount: 'The amount to quote',
                poolPath: 'The token pool path',
                tokenPath: 'The token swap path',
              },
              returns: {
                haircut: 'The total haircut that would be applied',
                potentialOutcome: 'The potential final amount user would receive',
              },
              notice:
                'Quotes potential outcome of a swap given current tokenPath and poolPath, taking in account slippage and haircut',
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_registry', type: 'address' },
                { internalType: 'uint64', name: 'version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'swapTokenForToken(address,address,uint256,uint256,address,address,uint256)': {
              inputs: [
                { internalType: 'address', name: 'fromToken', type: 'address' },
                { internalType: 'address', name: 'toToken', type: 'address' },
                { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'minAmount', type: 'uint256' },
                { internalType: 'address', name: 'from', type: 'address' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swapTokenForToken',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'haircut', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Swaps tokens using a Baluni V1 pool.',
              params: {
                deadline: 'The deadline by which the swap must be executed.',
                from: 'The address from which the tokens are being swapped.',
                fromAmount: 'The amount of tokens to swap from.',
                fromToken: 'The address of the token to swap from.',
                minAmount: 'The minimum amount of tokens to receive in the swap.',
                to: 'The address to which the tokens are being swapped.',
                toToken: 'The address of the token to swap to.',
              },
              returns: {
                amountOut: 'The amount of tokens received in the swap.',
                haircut: 'The haircut applied to the swap.',
              },
            },
            'swapTokensForTokens(address[],address[],uint256,uint256,address,uint256)': {
              inputs: [
                { internalType: 'address[]', name: 'tokenPath', type: 'address[]' },
                { internalType: 'address[]', name: 'poolPath', type: 'address[]' },
                { internalType: 'uint256', name: 'fromAmount', type: 'uint256' },
                { internalType: 'uint256', name: 'minimumToAmount', type: 'uint256' },
                { internalType: 'address', name: 'to', type: 'address' },
                { internalType: 'uint256', name: 'deadline', type: 'uint256' },
              ],
              name: 'swapTokensForTokens',
              outputs: [
                { internalType: 'uint256', name: 'amountOut', type: 'uint256' },
                { internalType: 'uint256', name: 'haircut', type: 'uint256' },
              ],
              stateMutability: 'nonpayable',
              type: 'function',
              details: 'Swaps tokens for tokens using a specified token path and pool path.',
              params: {
                deadline: 'The deadline for the swap to occur.',
                fromAmount: 'The amount of tokens to swap from.',
                minimumToAmount: 'The minimum amount of tokens to receive after swapping.',
                poolPath: 'The array of pool addresses representing the path of pools to use for swapping.',
                to: 'The address to receive the swapped tokens.',
                tokenPath: 'The array of token addresses representing the path of tokens to swap.',
              },
              returns: {
                amountOut: 'The amount of tokens received after swapping.',
                haircut: 'The amount of tokens deducted as a fee during the swap.',
              },
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/registry/BaluniV1PoolRegistry.sol:BaluniV1PoolRegistry': {
          source: 'contracts/registry/BaluniV1PoolRegistry.sol',
          name: 'BaluniV1PoolRegistry',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'PoolCreated(address,address[])': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'pool', type: 'address' },
                { indexed: !1, internalType: 'address[]', name: 'assets', type: 'address[]' },
              ],
              name: 'PoolCreated',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'addPool(address)': {
              inputs: [{ internalType: 'address', name: 'poolAddress', type: 'address' }],
              name: 'addPool',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'allPools(uint256)': {
              inputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              name: 'allPools',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getAllPools()': {
              inputs: [],
              name: 'getAllPools',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves all the pools created by the factory.',
              returns: { _0: 'An array of pool addresses.' },
            },
            'getPool(address,address)': {
              inputs: [
                { internalType: 'address', name: '', type: 'address' },
                { internalType: 'address', name: '', type: 'address' },
              ],
              name: 'getPool',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getPoolAssets(address)': {
              inputs: [{ internalType: 'address', name: 'poolAddress', type: 'address' }],
              name: 'getPoolAssets',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the assets of a specific pool.',
              params: { poolAddress: 'The address of the pool.' },
              returns: { _0: 'An array of asset addresses.' },
            },
            'getPoolByAssets(address,address)': {
              inputs: [
                { internalType: 'address', name: 'asset1', type: 'address' },
                { internalType: 'address', name: 'asset2', type: 'address' },
              ],
              name: 'getPoolByAssets',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the pool address based on the given assets.',
              params: { asset1: 'The address of the first asset.', asset2: 'The address of the second asset.' },
              returns: { _0: 'The address of the pool.' },
            },
            'getPoolsByAsset(address)': {
              inputs: [{ internalType: 'address', name: 'token', type: 'address' }],
              name: 'getPoolsByAsset',
              outputs: [{ internalType: 'address[]', name: '', type: 'address[]' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns an array of pool addresses that contain the specified token.',
              params: { token: 'The address of the token to search for.' },
              returns: { _0: 'An array of pool addresses.' },
            },
            'getPoolsCount()': {
              inputs: [],
              name: 'getPoolsCount',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Retrieves the number of pools created by the factory.',
              returns: { _0: 'The count of pools.' },
            },
            'initialize(address)': {
              inputs: [{ internalType: 'address', name: '_register', type: 'address' }],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'poolExist(address)': {
              inputs: [{ internalType: 'address', name: '_pool', type: 'address' }],
              name: 'poolExist',
              outputs: [{ internalType: 'bool', name: '', type: 'bool' }],
              stateMutability: 'view',
              type: 'function',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'registry()': {
              inputs: [],
              name: 'registry',
              outputs: [{ internalType: 'contract IBaluniV1Registry', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'reinitialize(address,uint64)': {
              inputs: [
                { internalType: 'address', name: '_register', type: 'address' },
                { internalType: 'uint64', name: '_version', type: 'uint64' },
              ],
              name: 'reinitialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
        'contracts/registry/BaluniV1Registry.sol:BaluniV1Registry': {
          source: 'contracts/registry/BaluniV1Registry.sol',
          name: 'BaluniV1Registry',
          events: {
            'Initialized(uint64)': {
              anonymous: !1,
              inputs: [{ indexed: !1, internalType: 'uint64', name: 'version', type: 'uint64' }],
              name: 'Initialized',
              type: 'event',
              details: 'Triggered when the contract has been initialized or reinitialized.',
            },
            'OwnershipTransferred(address,address)': {
              anonymous: !1,
              inputs: [
                { indexed: !0, internalType: 'address', name: 'previousOwner', type: 'address' },
                { indexed: !0, internalType: 'address', name: 'newOwner', type: 'address' },
              ],
              name: 'OwnershipTransferred',
              type: 'event',
            },
            'Upgraded(address)': {
              anonymous: !1,
              inputs: [{ indexed: !0, internalType: 'address', name: 'implementation', type: 'address' }],
              name: 'Upgraded',
              type: 'event',
              details: 'Emitted when the implementation is upgraded.',
            },
          },
          methods: {
            'UPGRADE_INTERFACE_VERSION()': {
              inputs: [],
              name: 'UPGRADE_INTERFACE_VERSION',
              outputs: [{ internalType: 'string', name: '', type: 'string' }],
              stateMutability: 'view',
              type: 'function',
            },
            'USDC()': {
              inputs: [],
              name: 'USDC',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'WNATIVE()': {
              inputs: [],
              name: 'WNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_1inchSpotAgg()': {
              inputs: [],
              name: '_1inchSpotAgg',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_BPS_BASE()': {
              inputs: [],
              name: '_BPS_BASE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_BPS_FEE()': {
              inputs: [],
              name: '_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            '_MAX_BPS_FEE()': {
              inputs: [],
              name: '_MAX_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniAgentFactory()': {
              inputs: [],
              name: 'baluniAgentFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniOracle()': {
              inputs: [],
              name: 'baluniOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniPoolPeriphery()': {
              inputs: [],
              name: 'baluniPoolPeriphery',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniPoolRegistry()': {
              inputs: [],
              name: 'baluniPoolRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniRebalancer()': {
              inputs: [],
              name: 'baluniRebalancer',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniRegistry()': {
              inputs: [],
              name: 'baluniRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniRouter()': {
              inputs: [],
              name: 'baluniRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'baluniSwapper()': {
              inputs: [],
              name: 'baluniSwapper',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'get1inchSpotAgg()': {
              inputs: [],
              name: 'get1inchSpotAgg',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBPS_BASE()': {
              inputs: [],
              name: 'getBPS_BASE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBPS_FEE()': {
              inputs: [],
              name: 'getBPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniAgentFactory()': {
              inputs: [],
              name: 'getBaluniAgentFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniOracle()': {
              inputs: [],
              name: 'getBaluniOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniPoolPeriphery()': {
              inputs: [],
              name: 'getBaluniPoolPeriphery',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniPoolRegistry()': {
              inputs: [],
              name: 'getBaluniPoolRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRebalancer()': {
              inputs: [],
              name: 'getBaluniRebalancer',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRegistry()': {
              inputs: [],
              name: 'getBaluniRegistry',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniRouter()': {
              inputs: [],
              name: 'getBaluniRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getBaluniSwapper()': {
              inputs: [],
              name: 'getBaluniSwapper',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getMAX_BPS_FEE()': {
              inputs: [],
              name: 'getMAX_BPS_FEE',
              outputs: [{ internalType: 'uint256', name: '', type: 'uint256' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getStaticOracle()': {
              inputs: [],
              name: 'getStaticOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getTreasury()': {
              inputs: [],
              name: 'getTreasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUSDC()': {
              inputs: [],
              name: 'getUSDC',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUniswapFactory()': {
              inputs: [],
              name: 'getUniswapFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getUniswapRouter()': {
              inputs: [],
              name: 'getUniswapRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'getWNATIVE()': {
              inputs: [],
              name: 'getWNATIVE',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'initialize()': {
              inputs: [],
              name: 'initialize',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'owner()': {
              inputs: [],
              name: 'owner',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
              details: 'Returns the address of the current owner.',
            },
            'proxiableUUID()': {
              inputs: [],
              name: 'proxiableUUID',
              outputs: [{ internalType: 'bytes32', name: '', type: 'bytes32' }],
              stateMutability: 'view',
              type: 'function',
              details:
                "Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation's compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.",
            },
            'renounceOwnership()': {
              inputs: [],
              name: 'renounceOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.',
            },
            'set1inchSpotAgg(address)': {
              inputs: [{ internalType: 'address', name: '__1inchSpotAgg', type: 'address' }],
              name: 'set1inchSpotAgg',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBPS_FEE(uint256)': {
              inputs: [{ internalType: 'uint256', name: '__BPS_FEE', type: 'uint256' }],
              name: 'setBPS_FEE',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniAgentFactory(address)': {
              inputs: [{ internalType: 'address', name: '_baluniAgentFactory', type: 'address' }],
              name: 'setBaluniAgentFactory',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniOracle(address)': {
              inputs: [{ internalType: 'address', name: '_baluniOracle', type: 'address' }],
              name: 'setBaluniOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniPoolPeriphery(address)': {
              inputs: [{ internalType: 'address', name: '_baluniPoolPeriphery', type: 'address' }],
              name: 'setBaluniPoolPeriphery',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniPoolRegistry(address)': {
              inputs: [{ internalType: 'address', name: '_baluniPoolRegistry', type: 'address' }],
              name: 'setBaluniPoolRegistry',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRebalancer(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRebalancer', type: 'address' }],
              name: 'setBaluniRebalancer',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRegistry(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRegistry', type: 'address' }],
              name: 'setBaluniRegistry',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniRouter(address)': {
              inputs: [{ internalType: 'address', name: '_baluniRouter', type: 'address' }],
              name: 'setBaluniRouter',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setBaluniSwapper(address)': {
              inputs: [{ internalType: 'address', name: '_baluniSwapper', type: 'address' }],
              name: 'setBaluniSwapper',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setStaticOracle(address)': {
              inputs: [{ internalType: 'address', name: '_staticOracle', type: 'address' }],
              name: 'setStaticOracle',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setTreasury(address)': {
              inputs: [{ internalType: 'address', name: '_treasury', type: 'address' }],
              name: 'setTreasury',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUSDC(address)': {
              inputs: [{ internalType: 'address', name: '_USDC', type: 'address' }],
              name: 'setUSDC',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUniswapFactory(address)': {
              inputs: [{ internalType: 'address', name: '_uniswapFactory', type: 'address' }],
              name: 'setUniswapFactory',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setUniswapRouter(address)': {
              inputs: [{ internalType: 'address', name: '_uniswapRouter', type: 'address' }],
              name: 'setUniswapRouter',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'setWNATIVE(address)': {
              inputs: [{ internalType: 'address', name: '_WNATIVE', type: 'address' }],
              name: 'setWNATIVE',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
            },
            'staticOracle()': {
              inputs: [],
              name: 'staticOracle',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'transferOwnership(address)': {
              inputs: [{ internalType: 'address', name: 'newOwner', type: 'address' }],
              name: 'transferOwnership',
              outputs: [],
              stateMutability: 'nonpayable',
              type: 'function',
              details:
                'Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.',
            },
            'treasury()': {
              inputs: [],
              name: 'treasury',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'uniswapFactory()': {
              inputs: [],
              name: 'uniswapFactory',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'uniswapRouter()': {
              inputs: [],
              name: 'uniswapRouter',
              outputs: [{ internalType: 'address', name: '', type: 'address' }],
              stateMutability: 'view',
              type: 'function',
            },
            'upgradeToAndCall(address,bytes)': {
              inputs: [
                { internalType: 'address', name: 'newImplementation', type: 'address' },
                { internalType: 'bytes', name: 'data', type: 'bytes' },
              ],
              name: 'upgradeToAndCall',
              outputs: [],
              stateMutability: 'payable',
              type: 'function',
              'custom:oz-upgrades-unsafe-allow-reachable': 'delegatecall',
              details:
                'Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.',
            },
          },
        },
      }
      new Jn({
        el: '#app',
        router: new Mp({
          routes: [
            { path: '/', component: Hp, props: () => ({ json: Gp }) },
            { path: '*', component: Wp, props: (e) => ({ json: Gp[e.path.slice(1)] }) },
          ],
        }),
        mounted() {
          document.dispatchEvent(new Event('render-event'))
        },
        render: (e) => e(Rp),
      })
    })()
})()
