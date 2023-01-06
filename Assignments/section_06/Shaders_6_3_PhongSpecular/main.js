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
    this.camera_.position.set(2, 1, 7);

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
    
    this.onWindowResize_();
    this.raf_();
  }

  async setupProject_() {
    const vsh = await (await fetch('./shaders/vertex-shader.glsl')).text();
    const fsh = await (await fetch('./shaders/fragment-shader.glsl')).text();

    // create suzanne material
    const checkerBoardTexture = new THREE.TextureLoader().load('../resources/uvCheckerBoard.jpg');
    const suzanneMaterial = new THREE.ShaderMaterial({
      uniforms: {
        diffuseTexture : {value : checkerBoardTexture}
      },
      vertexShader: vsh,
      fragmentShader: fsh
    });

    // load suzanne mesh and add to scene
    const loader = new GLTFLoader();
    loader.setPath('../resources/');
    loader.load('suzanne.glb', (gltf) => {
      gltf.scene.traverse(c => {
        c.material = suzanneMaterial;
        c.position.set(1,0,0);
      });
      this.scene_.add(gltf.scene);
    });

    // create sphere material
    const brickTexture = new THREE.TextureLoader().load('../resources/brickTexture.jpg');
    const sphereMaterial = new THREE.ShaderMaterial({
      uniforms: {
        diffuseTexture : {value : brickTexture}
      },
      vertexShader: vsh,
      fragmentShader: fsh
    });

    // create sphere mesh and add to scene
    const sphereGeometry = new THREE.SphereGeometry(1,128,128); 
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
    sphere.position.set(-1,0,0);
    this.scene_.add(sphere);
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
