import * as THREE from 'https://cdn.skypack.dev/three@0.136';

import {GLTFLoader} from 'https://cdn.skypack.dev/three@0.136/examples/jsm/loaders/GLTFLoader.js';
import {OrbitControls} from 'https://cdn.skypack.dev/three@0.136/examples/jsm/controls/OrbitControls.js';


class SimonDevGLSLCourse {
  constructor() {
  }

  async initialize() {
    this.threejs_ = new THREE.WebGLRenderer();
    this.threejs_.outputEncoding = THREE.sRGBEncoding;
    document.body.appendChild(this.threejs_.domElement);

    window.addEventListener('resize', () => {
      this.onWindowResize_();
    }, false);

    this.scene_ = new THREE.Scene();

    this.camera_ = new THREE.PerspectiveCamera(60, 1920.0 / 1080.0, 0.1, 1000.0);
    this.camera_.position.set(1, 0, 5);

    const controls = new OrbitControls(this.camera_, this.threejs_.domElement);
    controls.target.set(0, 0, 0);
    controls.update();

    const loader = new THREE.CubeTextureLoader();
    const texture = loader.load([
        '../resources/Cold_Sunset__Cam_2_Left+X.png',
        '../resources/Cold_Sunset__Cam_3_Right-X.png',
        '../resources/Cold_Sunset__Cam_4_Up+Y.png',
        '../resources/Cold_Sunset__Cam_5_Down-Y.png',
        '../resources/Cold_Sunset__Cam_0_Front+Z.png',
        '../resources/Cold_Sunset__Cam_1_Back-Z.png',
    ]);

    this.scene_.background = texture;

    await this.setupProject_();

    this.previousRAF_ = null;
    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await fetch('./shaders/vertex-shader.glsl');
    const fsh = await fetch('./shaders/fragment-shader.glsl');

    const material = new THREE.ShaderMaterial({
      uniforms: {
        specMap: {
          value: this.scene_.background
        },
        time: {
          value: 0.0,
        }
      },
      vertexShader: await vsh.text(),
      fragmentShader: await fsh.text()
    });

    this.material_ = material;

    const geometry = new THREE.IcosahedronGeometry(1, 128);
    const mesh = new THREE.Mesh(geometry, material);
    mesh.position.set(-1,0,0);
    this.scene_.add(mesh);

    const cubeMesh = new THREE.Mesh(new THREE.BoxGeometry(1,1,1), material);
    cubeMesh.position.set(1,0,0);
    this.scene_.add(cubeMesh);

    this.totalTime_ = 0;
  }

  onWindowResize_() {
    this.threejs_.setSize(window.innerWidth, window.innerHeight);

    this.camera_.aspect = window.innerWidth / window.innerHeight;
    this.camera_.updateProjectionMatrix();
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
