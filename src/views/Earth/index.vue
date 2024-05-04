<script setup>
import {onMounted, render, ref} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { Line2 } from 'three/examples/jsm/lines/Line2.js';
import { LineMaterial } from 'three/examples/jsm/lines/LineMaterial.js';
import { LineGeometry } from 'three/examples/jsm/lines/LineGeometry.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import earthVertexShader from './shader/vertex.glsl?raw'
import earthFragmentShader from './shader/fragment.glsl?raw'

import earthVertexShader2 from './shader/vertex2.glsl?raw'
import earthFragmentShader2 from './shader/fragment2.glsl?raw'

import atomsphereVertexShader from './shader/atomsphere/vertex.glsl?raw'
import atomsphereFragmentShader from './shader/atomsphere/fragment.glsl?raw'






import * as TWEEN from '@tweenjs/tween.js';
import gsap from 'gsap'

let flyLineFlag;
let feixian = ref('移除飞线')


let base,controls,gui,clock,earth,sunSherical,shereMaterial,earthParameters,atomsphereMaterial,sizes;
const radius = 5
const group = new THREE.Group();
let map = new THREE.Object3D();
const groupDots = new THREE.Group();
	const groupLines = new THREE.Group();
	const groupHalo = new THREE.Group(); //卫星环+小卫星
	const aGroup = new THREE.Group();
	var initFlag = false;
	var WaveMeshArr = [];//所有波动光圈集合
let selectedLineMaterial = new THREE.MeshBasicMaterial({color:"#ffffff"})
var planGeometry = new THREE.PlaneGeometry( 1, 1 ); //默认在XOY平面上
var uniforms2 = {
		u_time: { value: 0.0 }
	};
//模拟的空间坐标 已经通过经纬度转换了
const posArr = [
		{ 'x': - 1.7049594735603837, 'y': 3.208354470512221, 'z': - 3.4350509144786985 },
		{ 'x': - 2.1965610576118175, 'y': 2.1955955192304506, 'z': - 3.9184792759587768 },
		{ 'x': - 2.2290975556080355, 'y': 2.6054406912933263, 'z': - 3.639066211507457 },
		{ 'x': 0.5738958419746141, 'y': - 0.44114968930852216, 'z': 4.9473255920938985 },
		{ 'x': - 0.9326350073394328, 'y': 2.8399222968004114, 'z': - 4.00812091773949 },
		{ 'x': 3.469198597393574, 'y': 1.2295167303380952, 'z': - 3.3842206934036057 },
		{ 'x': - 2.4019084876611916, 'y': - 2.190220428765315, 'z': 3.7991801866087123 },
		{ 'x': - 2.49363689878109, 'y': - 4.099696049856375, 'z': 1.4050862307450966 },
		{ 'x': - 2.3729307780326305, 'y': 2.840227787960863, 'z': 3.3618901878497454 },
		{ 'x': - 2.0636200279017873, 'y': 0.7444294629976027, 'z': - 4.493027615657812 },
		{ 'x': 0.47725894517680106, 'y': 2.4327372143508037, 'z': - 4.34212085796347 },
		{ 'x': - 2.4777001955161246, 'y': - 1.2092952460724242, 'z': 4.171163716394502 },
		{ 'x': - 0.03915748918627658, 'y': - 0.008362945319338826, 'z': 4.999839672648135 },
		{ 'x': 1.5223738738260317, 'y': - 1.032865814102439, 'z': - 4.649254348640267 },
		{ 'x': - 0.26640112020426315, 'y': - 4.314854187280748, 'z': 2.5121830716848077 },
		{ 'x': - 4.031470206741836, 'y': - 2.606648761952297, 'z': - 1.3973654511134501 },
		{ 'x': 0.8544382232162094, 'y': 1.5274953155132989, 'z': 4.683662390031124 },
		{ 'x': 3.0409624989238546, 'y': 1.76433738825175, 'z': - 3.555230043268055 },
		{ 'x': - 4.721251023266457, 'y': 1.2354922989397954, 'z': - 1.0878177947459262 },
		{ 'x': 2.1518961827021106, 'y': 3.891904027152385, 'z': - 2.285262755638206 },
		{ 'x': 0.8501960736517479, 'y': - 2.851729208821255, 'z': - 4.018060123480341 },
		{ 'x': 2.5631840141785176, 'y': 4.263234820997851, 'z': - 0.5048926326370041 },
		{ 'x': - 0.4580143454812531, 'y': - 2.6523265200067385, 'z': 4.213714144386437 }
	];


onMounted(()=>{
    base = new Base()
    base.camera.position.set(-2.354053433579341,2.4237217808217872, -10.141028995838971)
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    base.renderer.setClearColor('#000011')
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

    const ambientLight = new THREE.AmbientLight( 0xcccccc, 1);
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
				directionalLight.position.set( - 1, 1, 1 );
	base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/MilkyWay/' );

				const cubeTexture = cubeTextureLoader.load( [
					"dark-s_nx.jpg", "dark-s_nx.jpg",
					"dark-s_ny.jpg", "dark-s_ny.jpg",
					"dark-s_nz.jpg", "dark-s_nz.jpg"
				] );

	//base.scene.background = cubeTexture;

   /**
     * Sizes
     */

     sizes = {
        width:window.innerWidth,
        height:window.innerHeight,
        pixelRatio:Math.min(window.devicePixelRatio,2)
    }


    const textureLoader = new THREE.TextureLoader()
    /**
     * Earth
     */


     earthParameters = {}
     earthParameters.atmosphereDayColor = '#00aaff'
     earthParameters.atomsphereTwilightColor = '#ff6600'


     gui
        .addColor(earthParameters,'atmosphereDayColor')
        .onChange(()=>{
            shereMaterial.uniforms.uAtomsphereDayColor.value.set(earthParameters.atmosphereDayColor)
            atomsphereMaterial.uniforms.uAtomsphereDayColor.value.set(earthParameters.atmosphereDayColor)
        })

        gui
        .addColor(earthParameters,'atomsphereTwilightColor')
        .onChange(()=>{
            shereMaterial.uniforms.uAtomsphereTwilightColor.value.set(earthParameters.atomsphereTwilightColor)
            atomsphereMaterial.uniforms.uAtomsphereTwilightColor.value.set(earthParameters.atomsphereTwilightColor)
        })


    //Textures
    const earthDayTexture = textureLoader.load('/earth/2k_earth_daymap.jpg')
    earthDayTexture.colorSpace = THREE.SRGBColorSpace
    earthDayTexture.anisotropy = 8
    const earthNightTexture = textureLoader.load('/earth/2k_earth_nightmap.jpg')
    earthNightTexture.colorSpace = THREE.SRGBColorSpace
    earthNightTexture.anisotropy = 8
    const earthCloudsTexture = textureLoader.load('/earth/2k_earth_clouds.jpg')
    earthCloudsTexture.anisotropy = 8
    const earthSpecularTexture = textureLoader.load('/earth/2k_earth_specular_map.tif')
    earthSpecularTexture.anisotropy = 8

    const shereGeometry = new THREE.SphereGeometry(5,64,64)
    shereMaterial = new THREE.ShaderMaterial({
        vertexShader:earthVertexShader,
        fragmentShader:earthFragmentShader,
        uniforms:{
            uDayTexture:new THREE.Uniform(earthDayTexture),
            uNightTexture:new THREE.Uniform(earthNightTexture),
            uCloudsTexture:new THREE.Uniform(earthCloudsTexture),
            uSpecularTexture:new THREE.Uniform(earthSpecularTexture),
            uSunDirection:new THREE.Uniform(new THREE.Vector3(0,0,1)),
            uAtomsphereDayColor:new THREE.Uniform(new THREE.Color(earthParameters.atmosphereDayColor)),
            uAtomsphereTwilightColor:new THREE.Uniform(new THREE.Color(earthParameters.atomsphereTwilightColor)),
        }
    })

    earth = new THREE.Mesh(shereGeometry,shereMaterial)

    group.add(earth)


    //Atomsphere
    atomsphereMaterial = new THREE.ShaderMaterial({
        side:THREE.BackSide,
        transparent:true,
        vertexShader:atomsphereVertexShader,
        fragmentShader:atomsphereFragmentShader,
        uniforms:{
            uSunDirection:new THREE.Uniform(new THREE.Vector3(0,0,1)),
            uAtomsphereDayColor:new THREE.Uniform(new THREE.Color(earthParameters.atmosphereDayColor)),
            uAtomsphereTwilightColor:new THREE.Uniform(new THREE.Color(earthParameters.atomsphereTwilightColor)),
        }
    })

    const atomshere = new THREE.Mesh(shereGeometry,atomsphereMaterial)
    atomshere.scale.set(1.04,1.04,1.04)
    base.scene.add(atomshere)


    /**
     * Sun
     */


     const debugSun = new THREE.Mesh(
        new THREE.IcosahedronGeometry(0.1,2),
        new THREE.MeshBasicMaterial()
    )

    base.scene.add(debugSun)

    sunSherical = new THREE.Spherical(1,Math.PI*0.5,0.5)
    const sunDirection = new THREE.Vector3()

    const updateSun = () =>{
        //Sun direction
        sunDirection.setFromSpherical(sunSherical)

        debugSun.position.copy(sunDirection).multiplyScalar(5)

        
        shereMaterial.uniforms.uSunDirection.value.copy(sunDirection)
        atomsphereMaterial.uniforms.uSunDirection.value.copy(sunDirection)
    }

    console.log(base.renderer.capabilities.getMaxAnisotropy())

    updateSun()


    //Tweeks
    gui
        .add(sunSherical,'phi')
        .min(0)
        .max(Math.PI)
        .onChange(updateSun)

    gui
        .add(sunSherical,'theta')
        .min(-Math.PI)
        .max(Math.PI)
        .onChange(updateSun)


    


    //外圈中国描边高亮
		initGeoJson();
    base.scene.add(group)

    
    //初始化点和曲线
			initDotAndFly();
			//光柱效果和底部矩形
			initLightPillar();
      initFlag = true;

    


    //controls 监听
	controls.addEventListener('change', () => {
	  // 当用户操作相机时，这里的代码会被调用
	  console.log('相机变换了',base.camera.position);
	});

             

    update()




});



/**
	 * 中国描边高亮
	 */
   function initGeoJson() {
		const loader = new THREE.FileLoader();
		loader.load( '/earth/json/geoJson/china.json', function ( data ) {
			const jsonData = JSON.parse( data );
			initMap( jsonData );
		} );
		loader.load( '/earth/json/geoJson/china-outline.json', function ( data ) {
			const jsonData = JSON.parse( data );
      console.log(jsonData)
			outLineMap( jsonData );
		} );
	}

  function initMap( chinaJson ) {
		// 遍历省份构建模型
		chinaJson.features.forEach( elem => {
			// 新建一个省份容器：用来存放省份对应的模型和轮廓线
			const province = new THREE.Object3D();
			const coordinates = elem.geometry.coordinates;
			coordinates.forEach( multiPolygon => {
				multiPolygon.forEach( polygon => {
					const lineMaterial = new THREE.LineBasicMaterial( { color: 0XF19553 } ); //0x3BFA9E
					const positions = [];
					const linGeometry = new THREE.BufferGeometry();
					for (let i = 0; i < polygon.length; i ++) {
						var pos = lglt2xyz( polygon[i][0], polygon[i][1] );
						positions.push( pos.x, pos.y, pos.z );
					}
					linGeometry.setAttribute( 'position', new THREE.Float32BufferAttribute( positions, 3 ) );
					const line = new THREE.Line( linGeometry, lineMaterial );
					province.add( line );
				} );
			} );
			map.add( province );

		} );
		group.add( map );
	}

  function outLineMap( json ) {
		json.features.forEach( elem => {
			// 新建一个省份容器：用来存放省份对应的模型和轮廓线
			const province = new THREE.Object3D();
			const coordinates = elem.geometry.coordinates;
			coordinates.forEach( multiPolygon => {
				multiPolygon.forEach( polygon => {
					// 这里的坐标要做2次使用：1次用来构建模型，1次用来构建轮廓线
					if (polygon.length > 200) {
						var v3ps = [];
						for (let i = 0; i < polygon.length; i ++) {
							var pos = lglt2xyz( polygon[i][0], polygon[i][1] );
							v3ps.push( pos );
						}
						var curve = new THREE.CatmullRomCurve3( v3ps, false/*是否闭合*/ );
						var color = new THREE.Vector3( 0.5999758518718452, 0.7798940272761521, 0.6181903838257632 );
						var flyLine = initFlyLine( curve, {
							speed: 0.4,
							// color: randomVec3Color(),
							color: color,
							number: 3, //同时跑动的流光数量
							length: 0.2, //流光线条长度
							size: 3 //粗细
						}, 5000 );
						province.add( flyLine );
					}
				} );
			} );
			map.add( province );
		} );
		group.add( map );
	}


  //threejs自带的经纬度转换
	function lglt2xyz( lng, lat ) {
		const theta = ( 90 + lng ) * ( Math.PI / 180 );
		const phi = ( 90 - lat ) * ( Math.PI / 180 );
		return ( new THREE.Vector3() ).setFromSpherical( new THREE.Spherical( radius, phi, theta ) );
	}

  /**
	 * @param curve {THREE.Curve} 路径,
	 * @param matSetting {Object} 材质配置项
	 * @param pointsNumber {Number} 点的个数 越多越细致
	 * */
	function initFlyLine( curve, matSetting, pointsNumber ) {
		var points = curve.getPoints( pointsNumber );
		var geometry = new THREE.BufferGeometry().setFromPoints( points );
		const length = points.length;
		var percents = new Float32Array( length );
		for (let i = 0; i < points.length; i += 1) {
			percents[i] = ( i / length );
		}
		geometry.setAttribute( 'percent', new THREE.BufferAttribute( percents, 1 ) );
		const lineMaterial = initLineMaterial( matSetting );
		var flyLine = new THREE.Points( geometry, lineMaterial );
		return flyLine;
	}

  function initLineMaterial( setting ) {
		const number = setting ? ( Number( setting.number ) || 1.0 ) : 1.0;
		const speed = setting ? ( Number( setting.speed ) || 1.0 ) : 1.0;
		const length = setting ? ( Number( setting.length ) || 0.5 ) : 0.5;
		const size = setting ? ( Number( setting.size ) || 3.0 ) : 3.0;
		const color = setting ? setting.color || new THREE.Vector3( 0, 1, 1 ) : new THREE.Vector3( 0, 1, 1 );
		const singleUniforms = {
			u_time: uniforms2.u_time,
			number: { type: 'f', value: number },
			speed: { type: 'f', value: speed },
			length: { type: 'f', value: length },
			size: { type: 'f', value: size },
			color: { type: 'v3', value: color }
		};
		const lineMaterial = new THREE.ShaderMaterial( {
			uniforms: singleUniforms,
			vertexShader:earthVertexShader2,
			fragmentShader: earthFragmentShader2,
			transparent: true,
			//blending:THREE.AdditiveBlending,
		} );
		return lineMaterial;
	}





  /**
	 * @description 初始化点和曲线
	 */
	function initDotAndFly() {
		// 创建标注点
		setRandomDot( groupDots );
		//随机点加载group上面
		group.add( groupDots );
		// 曲线
		var animateDots = [];
		console.info("第一个坐标是多少")
		console.info(groupDots.children[0].position)
		groupDots.children.forEach( elem => {
			if (groupDots.children[0].position.x == elem.position.x) {
				return true;
			}
			var line = addLines( groupDots.children[0].position, elem.position );
			groupLines.add( line.lineMesh );
			animateDots.push( line.curve.getPoints( 100 ) ); //这个是里面球
		} );
		group.add( groupLines );
		// 添加动画
		console.log(animateDots.length)
		for (let i = 0; i < animateDots.length; i ++) {
			const aGeo = new THREE.SphereGeometry( 0.03, 0.03, 0.03 );
			const aMater = new THREE.MeshPhongMaterial( { color: '#F8D764' } );
			const aMesh = new THREE.Mesh( aGeo, aMater );
			aGroup.add( aMesh );
		}
		var vIndex = 0;
		function animateLine() {
			aGroup.children.forEach( ( elem, index ) => {
				const v = animateDots[index][vIndex];
				elem.position.set( v.x, v.y, v.z );
			} );
			vIndex ++;
			if (vIndex > 100) {
				vIndex = 0;
			}
			setTimeout( animateLine, 20 );
		}
		group.add( aGroup );
		animateLine();
	}


  /**
	 * @desc 随机设置点
	 * @param <Group> group ...
	 * @param <number> radius ...
	 */
	function setRandomDot( group ) {
		var texture = new THREE.TextureLoader().load( '/earth/diqiu2/标注.png' );
		var texture2 = new THREE.TextureLoader().load( '/earth/diqiu2/标注光圈.png' );
		posArr.map( pos => {
			var dotMesh = createPointMesh( pos, texture );
			var waveMesh = createWaveMesh( pos, texture2 );
			group.add( dotMesh );
			group.add( waveMesh );
			WaveMeshArr.push( waveMesh );
		} );
	}

	/**
	 * 标注
	 */
	function createPointMesh( pos, texture ) {
		var material = new THREE.MeshBasicMaterial( {
			map: texture,
			transparent: true, //使用背景透明的png贴图，注意开启透明计算
			// side: THREE.DoubleSide, //双面可见
			depthWrite: false, //禁止写入深度缓冲区数据
		} );
		var mesh = new THREE.Mesh( planGeometry, material );
		var size = radius * 0.04;//矩形平面Mesh的尺寸
		mesh.scale.set( size, size, size );//设置mesh大小
		//设置mesh位置
		mesh.position.set( pos.x, pos.y, pos.z );
		// mesh在球面上的法线方向(球心和球面坐标构成的方向向量)
		var coordVec3 = new THREE.Vector3( pos.x, pos.y, pos.z ).normalize();
		// mesh默认在XOY平面上，法线方向沿着z轴new THREE.Vector3(0, 0, 1)
		var meshNormal = new THREE.Vector3( 0, 0, 1 );
		// 四元数属性.quaternion表示mesh的角度状态
		//.setFromUnitVectors();计算两个向量之间构成的四元数值
		mesh.quaternion.setFromUnitVectors( meshNormal, coordVec3 );
		return mesh;
	}


  /**
	 * 光柱效果
	 */
	function initLightPillar() {
		var texture = new THREE.TextureLoader().load( '/earth/diqiu2/标注.png' );
		var datas = [
			{
				lng: 86.39895905468748, lat: 45.15923349468924 //合肥
			},
			{
				lng: 106.54041, lat: 29.40268 //重庆
			}
		];
		datas.forEach( function ( obj ) {
			var pos = lglt2xyz( obj.lng, obj.lat );
			var LightPillar = createLightPillar( pos );
			groupDots.add( LightPillar );
			var waveMesh = createLightWaveMesh( pos, texture );
			LightPillar.add( waveMesh );
		} );
	}

	/**
	 * 标注的光圈
	 */
	function createWaveMesh( pos, texture ) {
		var material = new THREE.MeshBasicMaterial( {
			color: 0x22ffcc,
			map: texture,
			transparent: true, //使用背景透明的png贴图，注意开启透明计算
			opacity: 1.0,
			// side: THREE.DoubleSide, //双面可见
			depthWrite: false, //禁止写入深度缓冲区数据
		} );
		var mesh = new THREE.Mesh( planGeometry, material );
		// var coord = lon2xyz(R*1.001, lon, lat)
		var size = radius * 0.055;//矩形平面Mesh的尺寸
		mesh.size = size;//自顶一个属性，表示mesh静态大小
		mesh.scale.set( size, size, size );//设置mesh大小
		mesh._s = Math.random() * 1.0 + 1.0;//自定义属性._s表示mesh在原始大小基础上放大倍数  光圈在原来mesh.size基础上1~2倍之间变化
		mesh.position.set( pos.x, pos.y, pos.z );
		// mesh姿态设置
		// mesh在球面上的法线方向(球心和球面坐标构成的方向向量)
		var coordVec3 = new THREE.Vector3( pos.x, pos.y, pos.z ).normalize();
		// mesh默认在XOY平面上，法线方向沿着z轴new THREE.Vector3(0, 0, 1)
		var meshNormal = new THREE.Vector3( 0, 0, 1 );
		// 四元数属性.quaternion表示mesh的角度状态
		//.setFromUnitVectors();计算两个向量之间构成的四元数值
		mesh.quaternion.setFromUnitVectors( meshNormal, coordVec3 );
		return mesh;
	}

  /**
	 * 光柱特效
	 */
	function createLightPillar( pos ) {
		var height = radius * 0.1;//光柱高度，和地球半径相关，这样调节地球半径，光柱尺寸跟着变化
		var geometry = new THREE.PlaneGeometry( radius * 0.05, height ); //默认在XOY平面上
		geometry.rotateX( Math.PI / 2 );//光柱高度方向旋转到z轴上
		geometry.translate( 0, 0, height / 2 );//平移使光柱底部与XOY平面重合
		var textureLoader = new THREE.TextureLoader(); // TextureLoader创建一个纹理加载器对象
		var material = new THREE.MeshBasicMaterial( {
			map: textureLoader.load( '/earth/diqiu2/光柱.png' ),
			color: 0x44ffaa, //光柱颜色，光柱map贴图是白色，可以通过color调节颜色
			transparent: true, //使用背景透明的png贴图，注意开启透明计算
			side: THREE.DoubleSide, //双面可见
			depthWrite: false, //是否对深度缓冲区有任何的影响
		} );
		var mesh = new THREE.Mesh( geometry, material );
		var group = new THREE.Group();
		// 两个光柱交叉叠加
		group.add( mesh, mesh.clone().rotateZ( Math.PI / 2 ) );//几何体绕x轴旋转了，所以mesh旋转轴变为z
		group.position.set( pos.x, pos.y, pos.z );//设置mesh位置
		var coordVec3 = new THREE.Vector3( pos.x, pos.y, pos.z ).normalize();
		var meshNormal = new THREE.Vector3( 0, 0, 1 );
		// 四元数属性.quaternion表示mesh的角度状态
		//.setFromUnitVectors();计算两个向量之间构成的四元数值
		group.quaternion.setFromUnitVectors( meshNormal, coordVec3 );
		return group;
	}

  /**
	 * 光柱底部的矩形平面特效
	 */
	function createLightWaveMesh( pos, texture ) {
		var geometry = new THREE.PlaneGeometry( 1, 1 ); //默认在XOY平面上
		var material = new THREE.MeshBasicMaterial( {
			color: 0x22ffcc,
			map: texture,
			transparent: true, //使用背景透明的png贴图，注意开启透明计算
			// side: THREE.DoubleSide, //双面可见
			depthWrite: false, //禁止写入深度缓冲区数据
		} );
		var mesh = new THREE.Mesh( geometry, material );
		var size = radius * 0.05;//矩形平面Mesh的尺寸
		mesh.scale.set( size, size, size );//设置mesh大小
		return mesh;
	}


	// 添加飞线
	function addLines( v0, v3 ) {
		// 夹角
		var angle = ( v0.angleTo( v3 ) * 1.8 ) / Math.PI / 0.1; // 0 ~ Math.PI
		var aLen = angle * 0.4, hLen = angle * angle * 12;
		var p0 = new THREE.Vector3( 0, 0, 0 );
    console.log('angle',angle)

    console.log('aLen',aLen)

    console.log('hLen',hLen)
		// 法线向量
		var rayLine = new THREE.Ray( p0, getVCenter( v0.clone(), v3.clone() ) );
		// 顶点坐标
		var vtop = rayLine.at( hLen,rayLine.origin );

		//var vtop = rayLine.at( hLen / rayLine.at( 1 ).distanceTo( p0 ) );
    
		// 控制点坐标
		var v1 = getLenVcetor( v0.clone(), vtop, aLen );
		var v2 = getLenVcetor( v3.clone(), vtop, aLen );
		// 绘制三维三次贝赛尔曲线
		var curve = new THREE.CubicBezierCurve3( v0, v1, v2, v3 );
		var geometry = new LineGeometry();
		var points = curve.getSpacedPoints( 50 );
		var positions = [];
		var colors = [];
		var color = new THREE.Color();
		/**
		 * HSL中使用渐变
		 * h — hue value between 0.0 and 1.0
		 * s — 饱和度 between 0.0 and 1.0
		 * l — 亮度 between 0.0 and 1.0
		 */
		for (var j = 0; j < points.length; j ++) {
			color.setHSL( .31666+j*0.005,0.7, 0.7); //绿色
			//color.setHSL( .81666+j,0.88, 0.715+j*0.0025); //粉色
			colors.push( color.r, color.g, color.b );
			positions.push( points[j].x, points[j].y, points[j].z );
		}
		geometry.setPositions( positions );
		geometry.setColors( colors );
		var matLine = new LineMaterial( {
			linewidth: 0.001,
			vertexColors: true,
			dashed: false
		} );

		return {
			curve: curve,
			lineMesh: new Line2( geometry, matLine )
		};
	}

	// 计算v1,v2 的中点
	function getVCenter( v1, v2 ) {
		const v = v1.add( v2 );
		return v.divideScalar( 2 );
	}

	// 计算V1，V2向量固定长度的点
	function getLenVcetor( v1, v2, len ) {
		const v1v2Len = v1.distanceTo( v2 );
		return v1.lerp( v2, len / v1v2Len );
	}


  


  //相机运动
	function animateCamera(oldP, oldT, newP, newT,time) {
		// oldP  相机原来的位置
		// oldT  target原来的位置
		// newP  相机新的位置
		// newT  target新的位置
	    let tween = new TWEEN.Tween({
			x1: oldP.x, // 相机x
			y1: oldP.y, // 相机y
			z1: oldP.z, // 相机z
			x2: oldT.x, // 控制点的中心点x
			y2: oldT.y, // 控制点的中心点y
			z2: oldT.z  // 控制点的中心点z
		}).to({
			x1: newP.x,
			y1: newP.y,
			z1: newP.z,
			x2: newT.x,
			y2: newT.y,
			z2: newT.z
		}, time)
			.easing(TWEEN.Easing.Cubic.InOut)
			.onUpdate(function (object) {
				base.camera.position.x = object.x1;
				base.camera.position.y = object.y1;
				base.camera.position.z = object.z1;
				controls.target.x = object.x2;
				controls.target.y = object.y2;
				controls.target.z = object.z2;
				controls.update();
			}).start();
	}

function changeCamera(){

	
	
	
	/**点1{
    "x": 10.493978979892294,
    "y": 10.642208575141765,
    "z": -4.44937462309224
}**/
	let cameraClone = base.camera.clone()
	animateCamera(base.camera.position,new THREE.Vector3(0.0),new THREE.Vector3(cameraClone.position.x,cameraClone.position.y,-cameraClone.position.z),new THREE.Vector3(0.0))

}


function addFlyLine(){
  console.log('addFlyLine')

  flyLineFlag = !flyLineFlag

 if(!flyLineFlag){
  group.add(groupLines)
  feixian = "添加飞线"
 }else{
  group.remove(groupLines)
  feixian = '移除飞线'
 }

  
}




function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const elapsedTime = clock.getElapsedTime()
    
    uniforms2.u_time.value += 0.007;
  
    group.rotation.y = elapsedTime * 0.05
    requestAnimationFrame(update)

    if (initFlag) {
				//光环
				groupHalo.rotation.z = groupHalo.rotation.z + 0.01;
				group.rotation.y = group.rotation.y + 0.001;
				// 所有波动光圈都有自己的透明度和大小状态
				// 一个波动光圈透明度变化过程是：0~1~0反复循环
				if (WaveMeshArr.length) {
					WaveMeshArr.forEach( function ( mesh ) {
						mesh._s += 0.007;
						mesh.scale.set( mesh.size * mesh._s, mesh.size * mesh._s, mesh.size * mesh._s );
						if (mesh._s <= 1.5) {
							//mesh._s=1，透明度=0 mesh._s=1.5，透明度=1
							mesh.material.opacity = ( mesh._s - 1 ) * 2;
						} else if (mesh._s > 1.5 && mesh._s <= 2) {
							//mesh._s=1.5，透明度=1 mesh._s=2，透明度=0
							mesh.material.opacity = 1 - ( mesh._s - 1.5 ) * 2;
						} else {
							mesh._s = 1.0;
						}
					} );
				}
			}
    
    base.update()
    TWEEN.update()
    
    
}

function resize(){
    base.resize();
    base.renderer.setPixelRatio(sizes.pixelRatio)
}


</script>

<template>
  <div class="camera">
		<div class="camera-a" @click="addFlyLine">飞线</div>

    <div class="camera-a" @click="changeCamera">视角</div>
		
	</div>
</template>

<style scoped>
.camera{position:absolute;top:0;left:0;padding:10px;}
.camera>div{background:#333;color:#fff;padding:15px 30px;border:1px solid #fff;border-radius:2px;margin-top:10px;transition: all .4s;}

.camera>div:hover{background:#fff;color:#000;cursor: pointer;}

</style>