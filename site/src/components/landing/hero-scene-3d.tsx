"use client";

import { useRef, useState } from "react";
import { Canvas, useFrame } from "@react-three/fiber";
import { Float, Sphere, MeshDistortMaterial } from "@react-three/drei";
import * as THREE from "three";

/* Sphere lumineuse animee qui reagit au temps */
function GlowingSphere() {
  const meshRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.y = clock.getElapsedTime() * 0.15;
    meshRef.current.rotation.x = Math.sin(clock.getElapsedTime() * 0.1) * 0.1;
  });

  return (
    <Float speed={1.5} rotationIntensity={0.3} floatIntensity={0.8}>
      <Sphere ref={meshRef} args={[1.8, 64, 64]} position={[0, 0, 0]}>
        <MeshDistortMaterial
          color="#3b82f6"
          emissive="#1e40af"
          emissiveIntensity={0.4}
          roughness={0.2}
          metalness={0.8}
          distort={0.3}
          speed={2}
          transparent
          opacity={0.85}
        />
      </Sphere>
    </Float>
  );
}

/* Generateur deterministe de positions et couleurs */
function generateParticleData(count: number) {
  const positions = new Float32Array(count * 3);
  const colors = new Float32Array(count * 3);
  const palette = [
    new THREE.Color("#f97316"),
    new THREE.Color("#3b82f6"),
    new THREE.Color("#60a5fa"),
    new THREE.Color("#ffffff"),
  ];

  /* Seed pseudo-aleatoire basee sur ’ndex */
  const pseudo = (i: number) => {
    const x = Math.sin(i * 127.1 + 311.7) * 43758.5453;
    return x - Math.floor(x);
  };

  for (let i = 0; i < count; i++) {
    positions[i * 3] = (pseudo(i * 3) - 0.5) * 12;
    positions[i * 3 + 1] = (pseudo(i * 3 + 1) - 0.5) * 12;
    positions[i * 3 + 2] = (pseudo(i * 3 + 2) - 0.5) * 8;

    const c = palette[Math.floor(pseudo(i * 7) * palette.length)];
    colors[i * 3] = c.r;
    colors[i * 3 + 1] = c.g;
    colors[i * 3 + 2] = c.b;
  }

  return { positions, colors };
}

/* Particules flottantes autour de la sphere */
function Particles({ count = 150 }: { count?: number }) {
  const meshRef = useRef<THREE.Points>(null);
  const [data] = useState(() => generateParticleData(count));

  useFrame(({ clock }) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.y = clock.getElapsedTime() * 0.02;
    meshRef.current.rotation.x = Math.sin(clock.getElapsedTime() * 0.01) * 0.05;
  });

  return (
    <points ref={meshRef}>
      <bufferGeometry>
        <bufferAttribute attach="attributes-position" args={[data.positions, 3]} />
        <bufferAttribute attach="attributes-color" args={[data.colors, 3]} />
      </bufferGeometry>
      <pointsMaterial size={0.04} vertexColors transparent opacity={0.7} sizeAttenuation />
    </points>
  );
}

/* Anneau orbital */
function OrbitalRing() {
  const ringRef = useRef<THREE.Mesh>(null);

  useFrame(({ clock }) => {
    if (!ringRef.current) return;
    ringRef.current.rotation.z = clock.getElapsedTime() * 0.1;
    ringRef.current.rotation.x = 1.2 + Math.sin(clock.getElapsedTime() * 0.05) * 0.1;
  });

  return (
    <mesh ref={ringRef}>
      <torusGeometry args={[3, 0.015, 16, 100]} />
      <meshBasicMaterial color="#f97316" transparent opacity={0.5} />
    </mesh>
  );
}

export function HeroScene() {
  return (
    <div className="absolute inset-0 z-0" aria-hidden="true">
      <Canvas
        camera={{ position: [0, 0, 6], fov: 45 }}
        dpr={[1, 1.5]}
        gl={{ antialias: true, alpha: true }}
        style={{ background: "transparent" }}
      >
        <ambientLight intensity={0.3} />
        <directionalLight position={[5, 5, 5]} intensity={0.8} color="#94a3b8" />
        <pointLight position={[-3, -3, 2]} intensity={0.5} color="#f97316" />
        <pointLight position={[3, 2, -2]} intensity={0.4} color="#3b82f6" />

        <GlowingSphere />
        <OrbitalRing />
        <Particles count={150} />
      </Canvas>
    </div>
  );
}
