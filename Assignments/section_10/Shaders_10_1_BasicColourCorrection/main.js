import * as THREE from 'https://cdn.skypack.dev/three@0.136';


class SimonDevGLSLCourse {
  constructor() {
  }

  async initialize() {
    this.threejs_ = new THREE.WebGLRenderer();
    document.body.appendChild(this.threejs_.domElement);

    window.addEventListener('resize', () => {
      this.onWindowResize_();
    }, false);

    this.scene_ = new THREE.Scene();

    this.camera_ = new THREE.OrthographicCamera(0, 1, 1, 0, 0.1, 1000);
    this.camera_.position.set(0, 0, 1);

    await this.setupProject_();

    this.previousRAF_ = null;
    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch('./shaders/vertex-shader.glsl');
    const fsh = await fetch('./shaders/fragment-shader.glsl');

    const loader = new THREE.TextureLoader();
    const dogTexture = loader.load('./textures/dog.jpg');
    const plantsTexture = loader.load('./textures/tomato.jpg');
    const vignetteTexture = loader.load('./textures/vignette.jpg');
    plantsTexture.wrapS = THREE.ClampToEdgeWrapping;
    plantsTexture.wrapT = THREE.ClampToEdgeWrapping;
    plantsTexture.magFilter = THREE.NearestFilter;
    plantsTexture.minFilter = THREE.NearestFilter;
    dogTexture.magFilter = THREE.NearestFilter;
    dogTexture.minFilter = THREE.NearestFilter;

    // const video = document.getElementById('video');
    // video.play();

    // const videoTexture = new THREE.VideoTexture(video);

    const material = new THREE.ShaderMaterial({
      uniforms: {
        resolution: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) },
        time: { value: 0.0 },
        diffuse1: { value: dogTexture },
        diffuse2: { value: plantsTexture },
        vignette: { value: vignetteTexture },
      },
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text()
    });

    this.material_ = material;

    const geometry = new THREE.PlaneGeometry(1, 1);
    const plane = new THREE.Mesh(geometry, material);
    plane.position.set(0.5, 0.5, 0);
    this.scene_.add(plane);
    
    this.totalTime_ = 0;
  }

  onWindowResize_() {
    this.threejs_.setSize(window.innerWidth, window.innerHeight);
    this.material_.uniforms.resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
  }

  raf_() {
    requestAnimationFrame((t) => {
      if (this.previousRAF_ === null) {
        this.previousRAF_ = t;
      }

      this.step_(t - this.previousRAF_);
      this.threejs_.render(this.scene_, this.camera_);
      this.raf_();
      this.previousRAF_ = t;
    });
  }

  step_(timeElapsed) {
    const timeElapsedS = timeElapsed * 0.001;
    this.totalTime_ += timeElapsedS;

    this.material_.uniforms.time.value = this.totalTime_;
  }
}


let APP_ = null;

window.addEventListener('DOMContentLoaded', async () => {
  APP_ = new SimonDevGLSLCourse();
  await APP_.initialize();
});
