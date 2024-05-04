
uniform vec3 uSunDirection;
uniform vec3 uAtomsphereDayColor;
uniform vec3 uAtomsphereTwilightColor;

varying vec3 vNormal;
varying vec3 vPosition;


void main(){

        vec3 viewDirection = normalize(vPosition - cameraPosition);
        vec3 normal = normalize(vNormal);
        vec3 color = vec3(0.0);

        //Sun direction
        float sunOrientation = dot(uSunDirection,normal);



        //Atomsphere
        float atomsphereDayMix = smoothstep(-0.5,1.0,sunOrientation);
        vec3 atomsphereColor = mix(uAtomsphereTwilightColor,uAtomsphereDayColor,atomsphereDayMix);
        color += atomsphereColor;

        //Alpha
        float edgeAlpha = dot(viewDirection,normal);
        edgeAlpha = smoothstep(0.0,0.5,edgeAlpha);
        
        float dayAlpha = smoothstep(-0.5,0.0,sunOrientation);

        float alpha = edgeAlpha * dayAlpha;

       

        
       
        gl_FragColor = vec4(color,alpha);
        

        #include <tonemapping_fragment>
        #include <colorspace_fragment>

}