'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [err, setErr] = useState<string | null>(null);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) setErr(error.message);
    else router.push('/ai');
  }

  return (
    <main className="flex min-h-screen items-center justify-center">
      <form onSubmit={onSubmit} className="w-full max-w-sm rounded-lg border p-8">
        <h1 className="mb-6 text-2xl font-semibold">Gimma Admin</h1>
        <input type="email" className="mb-3 w-full rounded border p-2" placeholder="Email"
               value={email} onChange={(e) => setEmail(e.target.value)} required />
        <input type="password" className="mb-4 w-full rounded border p-2" placeholder="Password"
               value={password} onChange={(e) => setPassword(e.target.value)} required />
        {err && <p className="mb-3 text-sm text-red-600">{err}</p>}
        <button type="submit" className="w-full rounded bg-black p-2 text-white">Sign in</button>
      </form>
    </main>
  );
}
