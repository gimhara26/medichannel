import Link from "next/link";

export default function HomePage() {
  return (
    <main className="mx-auto max-w-5xl p-8">
      <header className="mb-10">
        <p className="text-sm font-semibold text-blue-700">Lanka Care Hospital</p>
        <h1 className="mt-2 text-4xl font-bold">MediChannel</h1>
        <p className="mt-3 text-slate-600">Find a doctor, book an appointment and follow your queue live.</p>
      </header>
      <nav className="flex flex-wrap gap-4">
        <Link className="rounded bg-blue-700 px-5 py-3 text-white" href="/doctors">Find a doctor</Link>
        <Link className="rounded border px-5 py-3" href="/login">Log in</Link>
        <Link className="rounded border px-5 py-3" href="/register">Register</Link>
      </nav>
    </main>
  );
}
