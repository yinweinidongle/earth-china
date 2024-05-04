uniform sampler2D uDayTexture;
uniform sampler2D uNightTexture;
uniform sampler2D uSpecularTexture;
uniform sampler2D uCloudsTexture;
uniform vec3 uSunDirection;
uniform vec3 uAtomsphereDayColor;
uniform vec3 uAtomsphereTwilightColor;

varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;




void main(){

        vec3 viewDirection = normalize(vPosition - cameraPosition);
        vec3 normal = normalize(vNormal);
        vec3 color = vec3(0.0);

        //Sun direction
        float sunOrientation = dot(uSunDirection,normal);


        //Day and Night color
        float dayMix = smoothstep(-0.25,0.5,sunOrientation);
        vec3 dayColor = texture(uDayTexture,vUv).rgb;
        vec3 nightColor = texture(uNightTexture,vUv).rgb;
        color = mix(nightColor,dayColor,dayMix);

        //Specular clouds color
        vec2 cloudsColor = texture(uCloudsTexture,vUv).rg;
        vec3 spColor = texture(uSpecularTexture,vUv).rgb;


        //Clouds
        float cloudsMix = smoothstep(0.5,1.0,cloudsColor.g);
        cloudsMix *= dayMix;
        color = mix(color,vec3(1.0),cloudsMix);


        //Fresnel
        float fresnel = dot(viewDirection,normal) + 1.0;
        fresnel = pow(fresnel,2.0);


        //Atomsphere
        float atomsphereDayMix = smoothstep(-0.5,1.0,sunOrientation);
        vec3 atomsphereColor = mix(uAtomsphereTwilightColor,uAtomsphereDayColor,atomsphereDayMix);
        color = mix(color,atomsphereColor,fresnel*atomsphereDayMix);
        

        //Specular
        vec3 reflection = reflect(-uSunDirection,normal);
        float specular = -dot(reflection,viewDirection);
        specular = max(specular,0.0);
        specular = pow(specular,32.0);

        vec3 specularColor = mix(vec3(1.0),atomsphereColor,fresnel);
        color += specular * specularColor;


       
        gl_FragColor = vec4(color,1.0);
        

        #include <tonemapping_fragment>
        #include <colorspace_fragment>

}