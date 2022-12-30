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
    
    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch('./shaders/vertex-shader.glsl');
    const fsh = await fetch('./shaders/fragment-shader.glsl');

    this.previousTime_ = performance.now();
    this.totalTime_ = 0.0; 

    const material = new THREE.ShaderMaterial({
      uniforms: {
        time : {value : this.totalTime_ }, 
        u_resolution: {value: new THREE.Vector2(window.innerWidth, window.innerHeight)}
      },
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text()
    });

    this.material = material;

    const geometry = new THREE.PlaneGeometry(1, 1);
    const plane = new THREE.Mesh(geometry, material);
    plane.position.set(0.5, 0.5, 0);
    this.scene_.add(plane);
  }

  onWindowResize_() {
    this.material.uniforms.u_resolution.value = new THREE.Vector2(window.innerWidth, window.innerHeight);
    console.log(`(${0},${1})`,window.innerWidth, window.innerHeight);
    this.threejs_.setSize(window.innerWidth, window.innerHeight);
  }

  raf_() {
    requestAnimationFrame((t) => {
      
      // Update time uniform
      const timeDelta = performance.now() - this.previousTime_;
      this.totalTime_ += timeDelta * 0.001;
      this.material.uniforms.time.value = this.totalTime_;
      this.previousTime_ = performance.now();

      this.threejs_.render(this.scene_, this.camera_);
      this.raf_();
    });
  }

}


let APP_ = null;

window.addEventListener('DOMContentLoaded', async () => {
  APP_ = new SimonDevGLSLCourse();
  await APP_.initialize();
});
