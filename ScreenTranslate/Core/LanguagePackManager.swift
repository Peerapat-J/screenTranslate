import Foundation
import Observation
import OSLog
import Translation

private let logger = Logger(subsystem: "com.app.screentranslate", category: "languagepack")

@MainActor
@Observable
final class LanguagePackManager {
    /// 개별 언어의 설치 상태 (쌍 기반이 아닌 개별 언어 기준)
    var languageStatuses: [String: LanguageStatus] = [:]

    enum LanguageStatus: Equatable {
        case installed
        case available   // 다운로드 가능 (미설치)
        case unsupported
    }

    private let availability = LanguageAvailability()

    /// 모든 언어의 개별 설치 상태를 교차 확인으로 판별한다.
    ///
    /// `LanguageAvailability.status(from:to:)`는 **언어 쌍** 상태를 반환하므로,
    /// 개별 언어 설치 여부를 알기 위해 여러 쌍을 교차 확인한다.
    /// 어떤 쌍이든 `.installed`이면 해당 쌍의 양쪽 언어 모두 개별 설치된 것으로 판단한다.
    func refreshAllStatuses() async {
        let langs = AppSettings.supportedLanguages
        var installedSet: Set<String> = []

        // Phase 1: 설치된 쌍을 찾아 개별 언어 설치 여부를 추론.
        // 최적화: 이미 설치 확인된 언어는 건너뛴다.
        for i in 0..<langs.count {
            guard !installedSet.contains(langs[i].code) else { continue }
            let from = Locale.Language(identifier: langs[i].code)
            for j in 0..<langs.count where i != j {
                let to = Locale.Language(identifier: langs[j].code)
                let status = await availability.status(from: from, to: to)
                if status == .installed {
                    installedSet.insert(langs[i].code)
                    installedSet.insert(langs[j].code)
                    break  // langs[i]가 설치됨을 확인, 다음 언어로
                }
            }
        }

        // Phase 2: 개별 상태 설정
        for lang in langs {
            if installedSet.contains(lang.code) {
                languageStatuses[lang.code] = .installed
            } else {
                // 미설치 언어: 설치된 언어와 쌍으로 지원 여부 확인
                if let ref = installedSet.first {
                    let from = Locale.Language(identifier: lang.code)
                    let to = Locale.Language(identifier: ref)
                    let status = await availability.status(from: from, to: to)
                    languageStatuses[lang.code] = (status == .unsupported) ? .unsupported : .available
                } else {
                    // 어떤 언어도 설치되지 않은 경우
                    languageStatuses[lang.code] = .available
                }
            }
        }

        logger.debug("개별 언어 상태: \(self.languageStatuses.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))")
    }

    /// 이미 설치된 언어 중 하나를 반환한다 (다운로드 트리거 시 쌍 구성용).
    func findInstalledLanguage(excluding code: String) -> String? {
        languageStatuses.first(where: { $0.key != code && $0.value == .installed })?.key
    }
}
