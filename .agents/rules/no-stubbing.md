---
description: Tests run real code against real infrastructure; stub only at the network edge
alwaysApply: true
---

# No Stubbing

A stub encodes what you believe a dependency does, so the test keeps passing when the real thing behaves differently. Run the real code instead.

Example: a stubbed `Rails.cache` hid that rate-limit counters in Memcached survive a database rollback. Refused sends used up customers' quota while every spec passed.

## Never stub

- **Your own code**: models, services, jobs, controllers. Build real records with factories and call the real code.
- **Infrastructure you run**: database, cache, queue, file system. Use the real one, or the framework's in-process version: `:memory_store` for `Rails.cache`, a temp directory for files, the test or inline adapter for jobs.
- **Time**: use `travel_to`, not `allow(Time)`.
- **ENV and config**: set the value for the example and restore it afterwards. Don't stub `ENV.fetch`.

## Stub only at the network edge

- Third-party HTTP APIs: stub at the HTTP layer (WebMock, VCR), not the client class.
- Hosts you don't run: DNS, remote SMTP, payment providers.
- Failures the real thing can't produce on demand, such as `Dalli::DalliError`, and only in the test for that failure.

## Assert outcomes, not calls

```ruby
# ❌ BAD: passes even if the counter is wrong
allow(Rails.cache).to receive(:increment).and_return(1)
expect(Rails.cache).to have_received(:increment).exactly(3).times

# ✅ GOOD: real store, real value
allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
described_class.call(message_params:, current_user: user, current_domain: domain)
expect(described_class.current_rate_limit_count(user, config)).to eq(3)
```

Swapping in a real implementation, as in the GOOD example, is fine. Replacing behaviour with canned return values is not.

When existing tests stub, don't add more. Replace the stubs in tests you touch.
