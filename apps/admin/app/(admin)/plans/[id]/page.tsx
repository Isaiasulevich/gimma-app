import Link from 'next/link';
import { PlanDisplay } from '@/components/plan-display';

export const dynamic = 'force-dynamic';

export default async function PlanDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return (
    <>
      <div className="mb-4">
        <Link className="text-sm text-neutral-500 hover:underline" href="/plans">← All plans</Link>
      </div>
      <PlanDisplay planId={id} />
    </>
  );
}
