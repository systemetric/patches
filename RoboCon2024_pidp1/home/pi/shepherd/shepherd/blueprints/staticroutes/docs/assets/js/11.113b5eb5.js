(window.webpackJsonp=window.webpackJsonp||[]).push([[11],{194:function(t,e,a){"use strict";a.r(e);var i=a(0),s=Object(i.a)({},(function(){var t=this,e=t.$createElement,a=t._self._c||e;return a("div",{staticClass:"content"},[t._m(0),t._v(" "),t._m(1),t._v(" "),t._m(2),t._v(" "),a("p",[t._v("I2C is a great way to a components to your BrainBox. Look at the datasheet for your device which you would like to connect and connect the SDA and SDL to the appropriate pins. You should now be able to send data to your device by using the "),a("a",{attrs:{href:"https://pypi.org/project/smbus2/",target:"_blank",rel:"noopener noreferrer"}},[t._v("SMBus2 python library"),a("OutboundLink")],1),t._v(".")]),t._v(" "),t._m(3),t._v(" "),a("p",[t._v("If you are interested in the I2C protocol there is a good guide to find out more about how it works "),a("a",{attrs:{href:"http://www.circuitbasics.com/basics-of-the-i2c-communication-protocol/",target:"_blank",rel:"noopener noreferrer"}},[t._v("here"),a("OutboundLink")],1),t._v(".")]),t._v(" "),t._m(4),t._v(" "),a("p",[t._v("You can use USB devices using the "),a("a",{attrs:{href:"https://pyserial.readthedocs.io/en/latest/shortintro.html",target:"_blank",rel:"noopener noreferrer"}},[a("code",[t._v("serial")]),a("OutboundLink")],1),t._v(" library. The connection will probably open on something similar to "),a("code",[t._v("dev/ttyUSB0")]),t._v(" but if you can't find it where you expect then connect the device to a Raspberry Pi running a recent OS image and observe where it appears.")]),t._v(" "),t._m(5),t._v(" "),a("p",[t._v("UART is not enabled by default on the BrainBox and you will need to ask on the forums for us to provide a patch to enable it should you wish to use it.")]),t._v(" "),t._m(6)])}),[function(){var t=this.$createElement,e=this._self._c||t;return e("h1",{attrs:{id:"expanding-functionality"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#expanding-functionality","aria-hidden":"true"}},[this._v("#")]),this._v(" Expanding Functionality")])},function(){var t=this.$createElement,e=this._self._c||t;return e("div",{staticClass:"warning custom-block"},[e("p",{staticClass:"custom-block-title"},[this._v("WARNING")]),this._v(" "),e("p",[this._v("Although the I2C and UART are connected to the Raspberry Pi, they operate at 5.1V not 3.3V. Check that your devices are compatible first!")])])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"i2c"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#i2c","aria-hidden":"true"}},[this._v("#")]),this._v(" I2C")])},function(){var t=this.$createElement,e=this._self._c||t;return e("div",{staticClass:"warning custom-block"},[e("p",{staticClass:"custom-block-title"},[this._v("WARNING")]),this._v(" "),e("p",[this._v("You should avoid address 0x08 (8) and 0x68 (104) because these are used by critical system components.")])])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"usb"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#usb","aria-hidden":"true"}},[this._v("#")]),this._v(" USB")])},function(){var t=this.$createElement,e=this._self._c||t;return e("h2",{attrs:{id:"uart"}},[e("a",{staticClass:"header-anchor",attrs:{href:"#uart","aria-hidden":"true"}},[this._v("#")]),this._v(" UART")])},function(){var t=this.$createElement,e=this._self._c||t;return e("div",{staticClass:"tip custom-block"},[e("p",{staticClass:"custom-block-title"},[this._v("TIP")]),this._v(" "),e("p",[this._v("Please ask on the forums for more infomation if you wish to expand your BrainBox.")])])}],!1,null,null,null);e.default=s.exports}}]);