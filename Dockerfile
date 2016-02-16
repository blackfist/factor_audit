FROM trenpixster/elixir:latest

RUN mkdir factor_audit

COPY . factor_audit
WORKDIR /factor_audit

RUN mix deps.get
RUN mix escript.build

ENV PATH "/factor_audit:$PATH"
ENTRYPOINT ["/factor_audit/factor_audit"]
