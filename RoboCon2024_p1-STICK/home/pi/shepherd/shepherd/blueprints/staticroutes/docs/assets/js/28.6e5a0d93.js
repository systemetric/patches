(window.webpackJsonp=window.webpackJsonp||[]).push([[28],{177:function(t,e,r){"use strict";r.r(e);var a=r(0),s=Object(a.a)({},(function(){var t=this,e=t.$createElement,r=t._self._c||e;return r("div",{staticClass:"content"},[t._m(0),t._v(" "),t._m(1),t._v(" "),t._m(2),t._v(" "),r("p",[t._v("Pressing the start button will cause the battery status LEDs on the front of the BrainBox flash in an upwards direction and the power LED turns green. When the user light starts flashing blue your BrainBox is ready to run code. You can now turn connect to your robot. The user LED will go solid while code is running.")]),t._v(" "),t._m(3),t._v(" "),r("p",[t._v("The BrainBox distributes power to the robot from the battery. It provides both 12V and 5V power out. All power must go through the BrainBox and the fuse should never be replaced.")]),t._v(" "),r("p",[t._v("The On/Off switch also plugs into the BrainBox as well as the Start button which is used to start your robot code running.")]),t._v(" "),t._m(4),t._v(" "),t._m(5),t._v(" "),t._m(6),t._v(" "),t._m(7),t._v(" "),t._m(8),t._v(" "),r("p",[t._v("When you are done for the day, press the power button, the user LED will flash rapidly, when this turns off you may unplug the battery.")]),t._v(" "),t._m(9),t._v(" "),r("p",[t._v("On the new brainBox, there is only one USB port. If you want to use something that requires a USB port such as a USB camera, you will need to get your own USB hub.")]),t._v(" "),t._m(10),t._v(" "),t._m(11),t._v(" "),r("p",[t._v("All of the BrainBox's GPIO pins are connected in-series with a 1K Ohm resistor, to provide current limiting. This means that you can plug devices such as LED's straight into your BrainBox.")]),t._v(" "),r("p",[t._v("Nominally they operate at 5V but depending on your load the true output will vary. You can calculate the voltage you will get across your load by measuring its resistance, then doing the sum:")]),t._v(" "),r("p",[t._v("(5*Load_resistance)/(Load_resistance+1000)")]),t._v(" "),t._m(12),t._v(" "),r("p",[t._v("We advise against you using analogue inputs with an impedance (You can think of impedance as \"effective resistance in an analogue circuit\") of greater than 9K Ohm's as this will result in values which do not necessarily correspond to what you'd expect.")]),t._v(" "),r("p",[t._v("If you need to sense something with an impedance of more than 9K then you will need to use an Op-amp to buffer the input. If you would like more details on how to do this please contact us on the forums.")]),t._v(" "),t._m(13),t._v(" "),r("p",[t._v("Do not try and sink or source more than 25mA into the BrainBox's GPIO, it may damage some of the internal components.")]),t._v(" "),t._m(14),t._v(" "),r("p",[t._v("PWM (Pulse Width Modulation) is a technique used for sending signals to a device for how much it should do a thing. This could be how fast to spin a motor, or the position to turn an RC Servo to. It does this by sending regular pulses, which vary in width. The length of the pulse tells the device how much to do the thing.  If you are interested you can find out more about using PWM for control "),r("a",{attrs:{href:"http://smartmicrocontroller.com/how-to-control-a-servo-using-pulse-width-modulation-pwm/",target:"_blank",rel:"noopener noreferrer"}},[t._v("here"),r("OutboundLink")],1),t._v(".")]),t._v(" "),r("p",[t._v("Please note you will not be able to drive large motors over the PWM pin's supplied as the maximum which they can supply is 3A at 5V.")]),t._v(" "),r("p",[t._v("The PWM pins ranges:")]),t._v(" "),t._m(15),t._v(" "),t._m(16),t._v(" "),t._m(17),t._v(" "),t._m(18),t._v(" "),t._m(19),t._v(" "),t._m(20),t._v(" "),t._m(21),t._v(" "),t._m(22),t._v(" "),t._m(23),t._v(" "),r("p",[t._v("For expansion please see the "),r("router-link",{attrs:{to:"/expanding-functionality.html"}},[t._v("expansion page")]),t._v(".")],1)])}),[function(){var t=this.$createElement,e=this._self._c||t;return e("h1",{attrs:{id:"the-brainbox"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#the-brainbox","aria-hidden":"true"}},[this._v("#")]),this._v(" The BrainBox")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v('The BrainBox is the core of the kit which we provide. In it is all of the electronics and software you need to power a robot. Lets start by turning it on. Take a battery from the kit and plug it into the yellow socket labelled battery, then take a red "power button" and connect that to the black connector along the side of the BrainBox. The battery and start button are both labelled on the red surface of the BrainBox.\n'),e("img",{attrs:{src:"/images/angled.png",alt:"The brain box"}})])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"how-to-turn-everything-on"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#how-to-turn-everything-on","aria-hidden":"true"}},[this._v("#")]),this._v(" How to turn everything on")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"power"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#power","aria-hidden":"true"}},[this._v("#")]),this._v(" Power")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"motors-12v-power"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#motors-12v-power","aria-hidden":"true"}},[this._v("#")]),this._v(" Motors & 12V Power")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[this._v("The specifications for the motor board can be found "),e("a",{attrs:{href:"/CytronBoardDocs.pdf"}},[this._v("here")]),this._v(", however to summarize:")])},function(){var t=this,e=t.$createElement,r=t._self._c||e;return r("table",[r("thead",[r("tr",[r("th",[t._v("Condition per channel")]),t._v(" "),r("th",[t._v("Maximum Value")])])]),t._v(" "),r("tbody",[r("tr",[r("td",[t._v("Continuous current")]),t._v(" "),r("td",[t._v("10A")])]),t._v(" "),r("tr",[r("td",[t._v("Peak current (10 seconds)")]),t._v(" "),r("td",[t._v("30A")])]),t._v(" "),r("tr",[r("td",[t._v("Operating Voltage")]),t._v(" "),r("td",[t._v("12V")])])])])},function(){var t=this.$createElement,e=this._self._c||t;return e("div",{staticClass:"tip custom-block"},[e("p",{staticClass:"custom-block-title"},[this._v("TIP")]),this._v(" "),e("p",[this._v("You can toggle the 12V which allows you to turn 12V devices on and off easily. However, this will also cut power to the motor board.")])])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"how-to-turn-everything-off"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#how-to-turn-everything-off","aria-hidden":"true"}},[this._v("#")]),this._v(" How to turn everything off")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"usb-s"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#usb-s","aria-hidden":"true"}},[this._v("#")]),this._v(" USB's")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"gpio"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#gpio","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"gpio-out"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#gpio-out","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO - Out")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"gpio-in"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#gpio-in","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO - In")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"gpio-limits"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#gpio-limits","aria-hidden":"true"}},[this._v("#")]),this._v(" GPIO - Limits")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"pwm-pins"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#pwm-pins","aria-hidden":"true"}},[this._v("#")]),this._v(" PWM Pins")])},function(){var t=this,e=t.$createElement,r=t._self._c||e;return r("table",[r("thead",[r("tr",[r("th",[t._v("Value")]),t._v(" "),r("th",[t._v("Pulse")])])]),t._v(" "),r("tbody",[r("tr",[r("td",[t._v("0")]),t._v(" "),r("td",[t._v("1.5ms")])]),t._v(" "),r("tr",[r("td",[t._v("100")]),t._v(" "),r("td",[t._v("2ms")])]),t._v(" "),r("tr",[r("td",[t._v("-100")]),t._v(" "),r("td",[t._v("1ms")])]),t._v(" "),r("tr",[r("td",[t._v("178")]),t._v(" "),r("td",[t._v("2.39ms")])]),t._v(" "),r("tr",[r("td",[t._v("-178")]),t._v(" "),r("td",[t._v("0.61ms")])])])])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"pin-out"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#pin-out","aria-hidden":"true"}},[this._v("#")]),this._v(" Pin Out")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"io"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#io","aria-hidden":"true"}},[this._v("#")]),this._v(" IO")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[e("img",{attrs:{src:"/images/powerconnector.png",alt:"USB's"}})])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"motors"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#motors","aria-hidden":"true"}},[this._v("#")]),this._v(" Motors")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[e("img",{attrs:{src:"/images/brainboxmotors.png",alt:"Motors"}})])},function(){var t=this.$createElement,e=this._self._c||t;return e("h3",{attrs:{id:"front"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#front","aria-hidden":"true"}},[this._v("#")]),this._v(" Front")])},function(){var t=this.$createElement,e=this._self._c||t;return e("p",[e("img",{attrs:{src:"/images/redpanel.png",alt:"Front"}})])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"expansion-i2c-uart-usb"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#expansion-i2c-uart-usb","aria-hidden":"true"}},[this._v("#")]),this._v(" Expansion I2C, UART & USB")])}],!1,null,null,null);e.default=s.exports}}]);