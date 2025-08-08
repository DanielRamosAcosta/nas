local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local s = import 'secrets.json';
local u = import 'utils.libsonnet';

local sftpgoConfig = importstr './sftpgo.config.json';

{
  local statefulSet = k.apps.v1.statefulSet,
  local container = k.core.v1.container,
  local containerPort = k.core.v1.containerPort,
  local secret = k.core.v1.secret,
  local volume = k.core.v1.volume,
  local volumeMount = k.core.v1.volumeMount,
  local configMap = k.core.v1.configMap,

  new(image='docker.io/drakkan/sftpgo', version):: {
    statefulSet: statefulSet.new('sftpgo', replicas=1, containers=[
                   container.new('sftpgo', u.image(image, version)) +
                   container.withPorts(
                     [containerPort.new('server', 2022)]
                   ) +
                   container.withEnv(
                     u.envVars.fromConfigMap(self.configEnv) +
                     u.envVars.fromSecret(self.secretsEnv),
                   ) +
                   container.withVolumeMounts([
                     volumeMount.new('data', '/srv/sftpgo'),
                     u.volumeMount.fromFile(self.configFile, '/etc/sftpgo'),
                   ]),
                 ]) +
                 u.injectFiles([self.configuration]) +
                 statefulSet.spec.template.spec.withVolumes([
                   volume.fromPersistentVolumeClaim('data', self.pvc.metadata.name),
                 ]),

    service: k.util.serviceFor(self.statefulSet),

    configuration: u.configMap.forFile("sftpgo.json", sftpgoConfig),

    secretsEnv: u.secret.forEnv(self.statefulSet, {
      DB_PASSWORD: s.POSTGRES_PASSWORD_IMMICH,
    }),

    pv: u.pv.localPathFor(self.statefulSet, '40Gi', '/cold-data/sftpgo/data'),
    pvc: u.pvc.from(self.pv),

    ingressRoute: u.ingressRoute.from(self.service, 'cloud.danielramos.me'),
  },
}
