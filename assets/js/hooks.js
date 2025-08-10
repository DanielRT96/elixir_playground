let Hooks = {}

Hooks.CameraPermission = {
  mounted() {
    this.controller = new AbortController()
    const signal = this.controller.signal

    this.handleClick = () => {
      navigator.mediaDevices.getUserMedia({ video: true })
        .then(stream => {
          console.log("Camera access granted")
          const video = document.getElementById("video")
          video.srcObject = stream
          video.classList.remove("hidden")
        })
        .catch(err => {
          console.error("Camera access denied:", err)
          alert("Camera access denied or not available.")
        })
    }
    this.el.addEventListener("click", this.handleClick, { signal })
  },

  destroy() {
    this.controller.abort();
  }
}


export default Hooks
