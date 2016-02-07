defmodule FactorAuditTest do
  use ExUnit.Case
  doctest FactorAudit

  test "it creates a valid start url" do
    assert FactorAudit.make_url("test") == "https://api.github.com/orgs/test/members?filter=2fa_disabled"
  end

  test "it extracts the next url from the headers" do
    headers = ["Access-Control-Allow-Credentials": "true", "Access-Control-Allow-Origin": "*",
      Link: "<https://api.github.com/organizations/111/members?page=2>; rel=\"next\", <https://api.github.com/organizations/111/members?page=9>; rel=\"last\"",
      Server: "GitHub.com", Status: "200 OK"]
    {:ok, next_link} = FactorAudit.get_next_link(headers)
    assert next_link == "https://api.github.com/organizations/111/members?page=2"
  end

  test "it returns an error when there is no next link" do
    headers = ["Access-Control-Allow-Credentials": "true", "Access-Control-Allow-Origin": "*",
      Link: "<https://api.github.com/organizations/111/members?page=1>; rel=\"first\", <https://api.github.com/organizations/111/members?page=8>; rel=\"prev\"",
      Server: "GitHub.com", Status: "200 OK"]
    assert {:error, :nolink} = FactorAudit.get_next_link(headers)
  end
end
