let Hooks = {}

Hooks.CameraPermission = {
  mounted() {
    this.el.addEventListener("click", () => {
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
    })
  }
}

export default Hooks
