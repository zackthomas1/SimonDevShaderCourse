import * as THREE from 'https://cdn.skypack.dev/three@0.136';

import {GLTFLoader} from 'https://cdn.skypack.dev/three@0.136/examples/jsm/loaders/GLTFLoader.js';
import {OrbitControls} from 'https://cdn.skypack.dev/three@0.136/examples/jsm/controls/OrbitControls.js';


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

    this.camera_ = new THREE.PerspectiveCamera(60, 1920.0 / 1080.0, 0.1, 1000.0);
    this.camera_.position.set(1, 0, 3);

    const controls = new OrbitControls(this.camera_, this.threejs_.domElement);
    controls.target.set(0, 0, 0);
    controls.update();

    const loader = new THREE.CubeTextureLoader();
    const texture = loader.load([
        './resources/Cold_Sunset__Cam_2_Left+X.png',
        './resources/Cold_Sunset__Cam_3_Right-X.png',
        './resources/Cold_Sunset__Cam_4_Up+Y.png',
        './resources/Cold_Sunset__Cam_5_Down-Y.png',
        './resources/Cold_Sunset__Cam_0_Front+Z.png',
        './resources/Cold_Sunset__Cam_1_Back-Z.png',
    ]);

    this.scene_.background = texture;

    await this.setupProject_();
    
    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch('./shaders/vertex-shader.glsl');
    const fsh = await fetch('./shaders/fragment-shader.glsl');

    const material = new THREE.ShaderMaterial({
      uniforms: {
      },
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text()
    });

    const loader = new GLTFLoader();
    loader.setPath('./resources/');
    loader.load('suzanne.glb', (gltf) => {
      gltf.scene.traverse(c => {
        c.material = material;
      });
      this.scene_.add(gltf.scene);
    });
  }

  onWindowResize_() {
    this.threejs_.setSize(window.innerWidth, window.innerHeight);

    this.camera_.aspect = window.innerWidth / window.innerHeight;
    this.camera_.updateProjectionMatrix();
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
