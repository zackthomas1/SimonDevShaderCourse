import * as THREE from 'https://cdn.skypack.dev/three@0.136';


class SimonDevGLSLCourse {
  constructor() {
  }

  async initialize() {
    this.threejs_ = new THREE.WebGLRenderer({
      antialias: true,
    });
    this.threejs_.shadowMap.enabled = true;
    this.threejs_.shadowMap.type = THREE.PCFSoftShadowMap;
    this.threejs_.setPixelRatio(window.devicePixelRatio);
    this.threejs_.setSize(window.innerWidth, window.innerHeight);

    document.body.appendChild(this.threejs_.domElement);

    window.addEventListener('resize', () => {
      this.onWindowResize_();
    }, false);

    this.camera_ = new THREE.OrthographicCamera(0, 1, 1, 0, 0.1, 1000);
    this.camera_.position.set(0, 0, 1);

    this.scene_ = new THREE.Scene();

    await this.setupProject_();
    
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch('./shaders/vertex-shader.glsl');
    const fsh = await fetch('./shaders/fragment-shader.glsl');

    const loader = new THREE.TextureLoader();
    const dogTexture = loader.load('./textures/dog.jpg');
    dogTexture.wrapS = THREE.RepeatWrapping;
    dogTexture.wrapT = THREE.RepeatWrapping;
    dogTexture.magFilter = THREE.NearestFilter;
    const overlayTexture = loader.load('./textures/overlay.png');

    const geometry = new THREE.PlaneGeometry(1, 1);
    const material = new THREE.ShaderMaterial({
      uniforms: {
        diffuse: {value: dogTexture},
        overlay: {value: overlayTexture},
        tint: {value: new THREE.Vector4(1, 0, 0, 1)},
      },
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text(),
    });

    const plane = new THREE.Mesh(geometry, material);
    plane.position.set(0.5, 0.5, 0);
    this.scene_.add( plane );
  }

  onWindowResize_() {
    this.threejs_.setSize(window.innerWidth, window.innerHeight);
  }

  raf_() {
    requestAnimationFrame((t) => {
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
