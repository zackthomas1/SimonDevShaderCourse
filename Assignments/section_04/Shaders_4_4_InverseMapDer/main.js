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
    const vsh = await fetch('./shaders/vertex-shader.glsl').then(response => response.text().catch(e =>console.error(e)));
    const fsh = await fetch('./shaders/fragment-shader.glsl').then(response => response.text().catch(e =>console.error(e)));

    const material = new THREE.ShaderMaterial({
      uniforms: {
        resolution: { value: new THREE.Vector2(
            window.innerWidth, window.innerHeight
        )}
      },
      vertexShader: vsh,
      fragmentShader: fsh
    });

    this.material_ = material;

    const geometry = new THREE.PlaneGeometry(1, 1);
    const plane = new THREE.Mesh(geometry, material);
    plane.position.set(0.5, 0.5, -0.5);
    plane.name = 'plane1';
    this.scene_.add(plane);

    const sphereGeometry = new THREE.SphereGeometry(.25,32,32); 
    const sphereMaterial = new THREE.MeshBasicMaterial({color: 0xff0000});
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.position.set(0.5, 0.5, -0.5);
    sphere.name = 'sphere1';
    this.scene_.add(sphere);

    this.totalTime_ = 0;
  }

  onWindowResize_() {
    this.threejs_.setSize(window.innerWidth, window.innerHeight);
    this.material_.uniforms.resolution.value = new THREE.Vector2(
        window.innerWidth, window.innerHeight);
  }

  raf_() {
    requestAnimationFrame((t) => {
      if (this.previousRAF_ === null) {
        this.previousRAF_ = t;
      }

      this.threejs_.render(this.scene_, this.camera_);
      this.raf_();
      this.previousRAF_ = t;
    });
  }

}


let APP_ = null;

window.addEventListener('DOMContentLoaded', async () => {
  APP_ = new SimonDevGLSLCourse();
  await APP_.initialize();
});
