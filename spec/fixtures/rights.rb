# frozen_string_literal: true

def mock_rights
  fake_rights = [
    {namespace: "inu", id: "30000113385391", attr: 2, reason: 1, source: 1, access_profile: 2, user: "name1", time: "2014-09-28 03:27:08"},

    {namespace: "mdp", id: "39015077958422", attr: 1, reason: 1, source: 1, access_profile: 2, user: "name2", time: "2020-12-04 03:25:36"},

    {namespace: "pur1", id: "32754074675400", attr: 1, reason: 1, source: 1, access_profile: 2, user: "name1", time: "2014-07-04 03:25:57"},
    {namespace: "inu", id: "30000000078026", attr: 2, reason: 1, source: 1, access_profile: 2, user: "name1", time: "2009-10-15 23:30:23"},
    {namespace: "inu", id: "30000000078232", attr: 2, reason: 1, source: 1, access_profile: 2, user: "name1", time: "2009-10-19 21:30:29"},
    {namespace: "inu", id: "30000000079024", attr: 1, reason: 1, source: 1, access_profile: 2, user: "name2 ", time: "2010-06-10 19:30:05"},
    {namespace: "uva", id: "x001592955", attr: 22, reason: 3, source: 1, access_profile: 2, user: "name3", time: "2020-03-19 16:57:04"}
  ]

  fake_rights.each do |fake|
    Services.rights_db[:rights_current].replace(fake)
  end
end
