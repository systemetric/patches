(window.webpackJsonp=window.webpackJsonp||[]).push([[19],{212:function(t,s,n){"use strict";n.r(s);var e=n(0),a=Object(e.a)({},(function(){var t=this,s=t.$createElement,n=t._self._c||s;return n("div",{staticClass:"content"},[t._m(0),t._v(" "),n("p",[t._v("GPIO, or General Purpose Input Output, is the main way you'll interface with simple or obscure bits of hardware. This tutorial will introduce the GPIO system and how to use it.")]),t._v(" "),t._m(1),t._v(" "),n("p",[t._v('On the side of your brainbox, there are 4 regular pins and a "+5v" and "-" pin. The top of the brain box labels which pin corresponds to which number. Different devices need to be plugged into different pins.')]),t._v(" "),t._m(2),t._v(" "),t._m(3),t._v(" "),t._m(4),t._v(" "),t._m(5),n("p",[t._v("Try using a loop to make the light turn on and off every 2 seconds. You'll need the time library from the motors exercise.")]),t._v(" "),t._m(6),t._v(" "),t._m(7),t._v(" "),t._m(8),n("p",[t._v("Try making a light turn on or off depending on if a button is pressed. An explaination of why it is needed to use "),n("code",[t._v("INPUT_PULLUP")]),t._v(" can be found in the "),n("router-link",{attrs:{to:"/gpio.html#pull-ups"}},[t._v("GPIO documentation")]),t._v(".")],1),t._v(" "),t._m(9),t._v(" "),t._m(10),t._v(" "),t._m(11)])}),[function(){var t=this.$createElement,s=this._self._c||t;return s("h1",{attrs:{id:"gpio"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#gpio","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO")])},function(){var t=this.$createElement,s=this._self._c||t;return s("h2",{attrs:{id:"gpio-pins"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#gpio-pins","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO Pins")])},function(){var t=this.$createElement,s=this._self._c||t;return s("h2",{attrs:{id:"led-output"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#led-output","aria-hidden":"true"}},[this._v("#")]),this._v(" LED Output")])},function(){var t=this.$createElement,s=this._self._c||t;return s("div",{staticClass:"tip custom-block"},[s("p",{staticClass:"custom-block-title"},[this._v("TIP")]),this._v(" "),s("p",[this._v("GPIO outputs are already protected by a 1k Ohm current limiting resistor, you can connect LEDs directly!")])])},function(){var t=this.$createElement,s=this._self._c||t;return s("p",[this._v("If you want to put an LED on your robot, for testing or just for looks, you'll need to plug one side of the LED into the "),s("code",[this._v("-")]),this._v(" (gound) pin, and the other side of the LED into any regular pin (such as 1). Then, use the following code to set up the pin in "),s("code",[this._v("OUTPUT")]),this._v(" mode and turn the LED on:")])},function(){var t=this,s=t.$createElement,n=t._self._c||s;return n("div",{staticClass:"language-python extra-class"},[n("pre",{pre:!0,attrs:{class:"language-python"}},[n("code",[n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("import")]),t._v(" robot\nR "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("Robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n\n"),n("span",{pre:!0,attrs:{class:"token comment"}},[t._v("# If you're not using GPIO pin 1, change this number to whatever pin you're using.")]),t._v("\nR"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("mode "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("OUTPUT\nR"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("digital "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" "),n("span",{pre:!0,attrs:{class:"token boolean"}},[t._v("True")]),t._v("\n")])])])},function(){var t=this.$createElement,s=this._self._c||t;return s("h2",{attrs:{id:"buttons"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#buttons","aria-hidden":"true"}},[this._v("#")]),this._v(" Buttons")])},function(){var t=this.$createElement,s=this._self._c||t;return s("p",[this._v("While your robot hopefully won't be colliding with much, buttons are a good way for a robot to know if it's driven into something. Buttons should be plugged into the - pin and a regular pin (such as 1). Using the "),s("code",[this._v("INPUT_PULLUP")]),this._v(" mode, you can detect when a button is pressed.")])},function(){var t=this,s=t.$createElement,n=t._self._c||s;return n("div",{staticClass:"language-python extra-class"},[n("pre",{pre:!0,attrs:{class:"language-python"}},[n("code",[n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("import")]),t._v(" robot\n"),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("import")]),t._v(" time\nR "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("Robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n\n"),n("span",{pre:!0,attrs:{class:"token comment"}},[t._v("# If you're not using GPIO pin 1, change this number to whatever pin you're using.")]),t._v("\nR"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("mode "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("INPUT\n\n"),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("while")]),t._v(" "),n("span",{pre:!0,attrs:{class:"token boolean"}},[t._v("True")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(":")]),t._v("\n    "),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("if")]),t._v(" R"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("1")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("digital"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(":")]),t._v("\n        "),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("print")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token string"}},[t._v('"Pressed"')]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    "),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("else")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(":")]),t._v("\n        "),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("print")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token string"}},[t._v('"Not Pressed"')]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n    time"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("sleep"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("0.1")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])])},function(){var t=this.$createElement,s=this._self._c||t;return s("h2",{attrs:{id:"potentiometers"}},[s("a",{staticClass:"header-anchor",attrs:{href:"#potentiometers","aria-hidden":"true"}},[this._v("#")]),this._v(" Potentiometers")])},function(){var t=this.$createElement,s=this._self._c||t;return s("p",[this._v("Another form of input is a potentiometer or a variable resistor. Potentiometers should be plugged into the +5v, a regular pin (such as 3) and the - pin. Using "),s("code",[this._v("INPUT_ANALOG")]),this._v(" mode, you can read the voltage output of the resistor (between 0V and 5V).")])},function(){var t=this,s=t.$createElement,n=t._self._c||s;return n("div",{staticClass:"language-python extra-class"},[n("pre",{pre:!0,attrs:{class:"language-python"}},[n("code",[n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("import")]),t._v(" robot\n\nR "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("Robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n\nPOT_PIN "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" "),n("span",{pre:!0,attrs:{class:"token number"}},[t._v("3")]),t._v("\n\nR"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),t._v("POT_PIN"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("mode "),n("span",{pre:!0,attrs:{class:"token operator"}},[t._v("=")]),t._v(" robot"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("INPUT_ANALOG\n\n"),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("while")]),t._v(" "),n("span",{pre:!0,attrs:{class:"token boolean"}},[t._v("True")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(":")]),t._v("\n    "),n("span",{pre:!0,attrs:{class:"token keyword"}},[t._v("print")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("(")]),t._v("R"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("gpio"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("[")]),t._v("POT_PIN"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v("]")]),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(".")]),t._v("analog"),n("span",{pre:!0,attrs:{class:"token punctuation"}},[t._v(")")]),t._v("\n")])])])}],!1,null,null,null);s.default=a.exports}}]);