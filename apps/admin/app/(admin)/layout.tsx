import { redirect } from 'next/navigation';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('role')
    .eq('id', user.id)
    .single();

  if (profile?.role !== 'admin') {
    return (
      <main className="flex min-h-screen items-center justify-center">
        <div className="rounded-lg border p-8">
          <h1 className="text-xl font-semibold">Not authorized</h1>
          <p className="mt-2 text-sm text-neutral-600">
            Your account is not an admin. Ask an admin to promote it.
          </p>
        </div>
      </main>
    );
  }

  return (
    <div className="flex min-h-screen">
      <aside className="w-52 border-r bg-neutral-50 p-4">
        <h1 className="mb-6 text-lg font-bold">Gimma Admin</h1>
        <nav className="flex flex-col gap-2 text-sm">
          <Link href="/ai" className="hover:underline">AI settings</Link>
          <Link href="/packs" className="hover:underline">Knowledge packs</Link>
          <Link href="/logs" className="hover:underline">AI call logs</Link>
          <Link href="/test-plan-gen" className="hover:underline">Test plan-gen</Link>
        </nav>
        <div className="mt-8 text-xs text-neutral-500">Signed in as {user.email}</div>
      </aside>
      <main className="flex-1 p-8">{children}</main>
    </div>
  );
}
