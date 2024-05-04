import * as THREE from 'three'
export default class Base{
    constructor(){
        this.scene = new THREE.Scene()
        this.camera = new THREE.PerspectiveCamera(
            75,
            window.innerWidth/window.innerHeight,
            0.1,
            100000
        )
        this.renderer = new THREE.WebGLRenderer({antialias:true})
        this.renderer.setSize(window.innerWidth,window.innerHeight)
        this.renderer.setPixelRatio(Math.min(window.devicePixelRatio,2))
        //this.renderer.setClearColor('#262837') //Haunted house
        this.renderer.setClearColor('#000000')
        this.renderer.shadowMap.enabled = true;
        this.renderer.shadowMap.type = THREE.PCFSoftShadowMap; // default 

        document.body.appendChild(this.renderer.domElement)
    }

    update(){
        this.renderer.render(this.scene,this.camera)
    }
    //自适应
    resize(){
        this.camera.aspect = window.innerWidth/window.innerHeight
        this.camera.updateProjectionMatrix()
        this.renderer.setSize(window.innerWidth,window.innerHeight)
    }

    addAmbientLight(intensity=0.5,color=0xffffff){
        const light = new THREE.AmbientLight(color,intensity)
        this.scene.add(light)
    }

    addDirectionalLight(intensity=1,color=0xffffff){
        const derectLight = new THREE.DirectionalLight(color,intensity)
        derectLight.castShadow = true; 
        this.scene.add(derectLight)
    }
}