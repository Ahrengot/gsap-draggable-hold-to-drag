# Hold to drag test in [GSAP draggable](http://greensock.com/draggable/)
The GreenSock Draggable utility has no built-in way to do hold-to-drag. This is a problem, when you have a full-screen draggable area on a touch screen, and want to retain the native scrolling functionality in the browser.

This example relies on [Hammer.js](http://eightmedia.github.io/hammer.js/) for the hold event.

### Re-shuffling of other elements
I kept out the re-shufling of other elements, when you drag around a list item, to make the code more concise. This is **NOT** a plug 'n play solution for a *full width drag 'n drop list on touch devices*, but merely a demo providing a solution for the missing hold-to-drag functionality.

However, I described how you can implement re-shuffling in [this issue](https://github.com/Ahrengot/gsap-draggable-hold-to-drag/issues/1)

### Example
Example on codepen: http://codepen.io/Ahrengot/pen/pdLiw
